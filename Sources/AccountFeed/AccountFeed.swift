import Foundation
import ComposableArchitecture
import APIClient
import Models
import Utils
import OrderedCollections

@Reducer
public struct AccountFeed {
    static let savingsGoalDefaultName = "Tech Challenge Round Up!"

    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: UUID { self.account.id }
        public struct RoundUpSavingsRequest: Equatable {
            var goal: SavingsGoal
            var amount: CurrencyAndAmount
        }

        var account: Account
        var feedItems: IdentifiedArrayOf<AccountFeedItem> = .init()
        var interval: DateInterval?
        var isLoading: Bool = false
        var isRoundingUp: Bool = false
        var apiErrors: OrderedSet<String> = .init()
        @Presents var alert: AlertState<Action.Alert>?

        public init(
            account: Account,
            apiErrors: OrderedSet<String> = .init(),
            alert: AlertState<Action.Alert>? = nil,
            interval: DateInterval? = nil,
            isLoading: Bool = false,
            feedItems: [AccountFeedItem] = [],
            isRoundingUp: Bool = false
        ) {
            self.account = account
            self.apiErrors = apiErrors
            self.alert = alert
            self.interval = interval
            self.isLoading = isLoading
            self.feedItems = .init(uniqueElements: feedItems)
            self.isRoundingUp = isRoundingUp
        }
    }

    public enum Action: ViewAction {
        case view(ViewAction)
        case feedItemsUpdated([AccountFeedItem])
        case intervalUpdated(DateInterval?)
        case isLoadingUpdated(Bool)
        case isRoundingUpdated(Bool)
        case apiErrorsUpdated(OrderedSet<String>)
        case alertUpdated(AlertState<Action.Alert>?)
        case alert(PresentationAction<Alert>)
        
        public enum Alert: Equatable {
            case refreshFeed
            case sendRoundUpAmountToSavingsGoal(request: State.RoundUpSavingsRequest)
            case savingsAccountCreationRequired
            case apiError(message: String)
        }

        public enum ViewAction {
            case task
            case nextWeekTapped
            case prevWeekTapped
            case roundUpTapped
        }
    }

    @Dependency(APIClient.self) var apiClient
    @Dependency(\.date) var date

    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .view(.task):
                return self.loadFeedItems(refDate: date(), state: &state)
            case .view(.prevWeekTapped):
                return self.loadFeedItemsPrevWeek(state: &state)
            case .view(.nextWeekTapped):
                return self.loadFeedItemsNextWeek(state: &state)
            case .view(.roundUpTapped):
                return self.handleRoundUp(state: &state)
            case .isLoadingUpdated(let flag):
                state.isLoading = flag
                return .none
            case let .alert(.presented(.apiError(message))):
                state.apiErrors.remove(message)
                self.alertErrorIfNeeded(state: &state)
                return .none
            case .alert(.presented(.savingsAccountCreationRequired)):
                return self.createSavingsGoal(state: &state)
            case .alert(.presented(.sendRoundUpAmountToSavingsGoal(let request))):
                return self.sendRoundUpToSavingsGoal(request: request, state: &state)
            case .alert(.presented(.refreshFeed)):
                return self.loadFeedItems(refDate: state.interval?.start ?? date(), state: &state)
            case .alert(.dismiss):
                if state.isRoundingUp {
                    state.isRoundingUp = false
                }
                return .none
            case .apiErrorsUpdated(let errors):
                state.apiErrors = errors
                self.alertErrorIfNeeded(state: &state)
                return .none
            case .feedItemsUpdated(let items):
                state.feedItems = .init(uniqueElements: items)
                return .none
            case .intervalUpdated(let interval):
                state.interval = interval
                return .none
            case .alertUpdated(let alert):
                state.alert = alert
                return .none
            case .isRoundingUpdated(let flag):
                state.isRoundingUp = flag
                return .none
            }
        }.ifLet(\.$alert, action: \.alert)
    }

    private func sendRoundUpToSavingsGoal(request: State.RoundUpSavingsRequest, state: inout State) -> Effect<Action> {
        state.isRoundingUp = true
        return .run { [state] send in
            let isMoneyTransferred = try await apiClient.transferToSavingsGoal(
                accountID: state.account.id.uuidString,
                savingsGoalID: request.goal.id.uuidString,
                amount: request.amount
            )
            
            guard isMoneyTransferred else {
                throw AppError(.unknown)
            }

            await send(.alertUpdated(.transferToSavingsGoalSuccessfullyAlert(request: request)))
            await send(.isRoundingUpdated(false))
        } catch: { [state] error, send in
            await self.handleError(error, state: state, send: send)
            await send(.isRoundingUpdated(false))
        }
    }

    private func createSavingsGoal(state: inout State) -> Effect<Action> {
        state.isRoundingUp = true
        return .run { [state] send in
            let goal = try await apiClient.createSavingsGoal(
                accountID: state.account.id.uuidString,
                name: AccountFeed.savingsGoalDefaultName,
                currency: state.account.currency
            )
            
            try await self.confirmRoundUp(for: goal, state: state, send: send)
        } catch: { [state] error, send in
            await self.handleError(error, state: state, send: send)
            await send(.isRoundingUpdated(false))
        }
    }

    private func handleRoundUp(state: inout State) -> Effect<Action> {
        state.isRoundingUp = true
        return .run { [state] send in
            let savingAccounts = try await apiClient.getSavingsGoals(accountID: state.account.id.uuidString)
            guard let targetGoal = savingAccounts.first else {
                await send(.alertUpdated(.currentSavingsGoalMissingAlert))
                return
            }
            
            try await self.confirmRoundUp(for: targetGoal, state: state, send: send)
        } catch: { [state] error, send in
            await self.handleError(error, state: state, send: send)
            await send(.isRoundingUpdated(false))
        }
    }

    private func confirmRoundUp(for goal: SavingsGoal, state: State, send: Send<AccountFeed.Action>) async throws {
        let outboundItems = state.feedItems.filter { $0.direction == .outbound }
        let currentAmounts = outboundItems.compactMap(\.amount)
        let roundedUpAmounts = currentAmounts.map { $0.roundedToNearestHundred() }

        let totalBeforeRoundingUp = currentAmounts.reduce(CurrencyAndAmount(currency: state.account.currency), +)
        let totalAfterRoundingUp = roundedUpAmounts.reduce(CurrencyAndAmount(currency: state.account.currency), +)

        let difference = totalAfterRoundingUp - totalBeforeRoundingUp
        let request = State.RoundUpSavingsRequest(goal: goal, amount: difference)
        await send(.alertUpdated(.transferToSavingsGoalAlert(request: request)))
    }
    
    private func handleError(_ error: Error, state: State, send: Send<AccountFeed.Action>) async {
        var errors = state.apiErrors
        errors.append(error.localizedDescription)
        await send(.apiErrorsUpdated(errors))
    }

    private func alertErrorIfNeeded(state: inout State) {
        if let nextMessage = state.apiErrors.first {
            state.alert = .apiErrorAlert(nextMessage)
        }
    }
    
    private func loadFeedItemsPrevWeek(state: inout State) -> Effect<Action> {
        guard !state.isLoading else {
            return .none
        }
        guard let currentWeek = state.interval else {
            return .none
        }
        
        let currentStartOfWeek = currentWeek.start
        let prevStartOfWeek = currentStartOfWeek.addingTimeInterval(-.oneWeek)
        return self.loadFeedItems(refDate: prevStartOfWeek, state: &state)
    }
    
    private func loadFeedItemsNextWeek(state: inout State) -> Effect<Action> {
        guard !state.isLoading else {
            return .none
        }
        guard let currentWeek = state.interval else {
            return .none
        }
        
        let currentStartOfWeek = currentWeek.start
        let nextStartOfWeek = currentStartOfWeek.addingTimeInterval(.oneWeek)
        return self.loadFeedItems(refDate: nextStartOfWeek, state: &state)
    }

    private func loadFeedItems(refDate: Date, state: inout State) -> Effect<Action> {
        state.isLoading = true
        return .run { [state] send in
            guard let startOfWeek = refDate.startOfWeek() else {
                throw AppError(.unknown)
            }

            let interval = DateInterval(start: startOfWeek, duration: .oneWeek)
            let items = try await self.apiClient.getAccountFeed(
                accountID: state.account.id.uuidString,
                categoryID: state.account.defaultCategory,
                interval: interval
            )
            await send(.feedItemsUpdated(items))
            await send(.intervalUpdated(interval))
            await send(.isLoadingUpdated(false))
        } catch: { [state] error, send in
            await self.handleError(error, state: state, send: send)
            await send(.isLoadingUpdated(false))
        }
    }
}
