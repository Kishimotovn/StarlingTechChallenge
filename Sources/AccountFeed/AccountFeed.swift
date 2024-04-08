import Foundation
import ComposableArchitecture
import APIClient
import Models
import Utils

@Reducer
public struct AccountFeed {
    
    @ObservableState
    public struct State: Equatable {
        var account: Account
        var feedItems: IdentifiedArrayOf<AccountFeedItem> = .init()
        var interval: DateInterval?
        var isLoading: Bool = false

        public init(account: Account) {
            self.account = account
        }
    }

    public enum Action: ViewAction {
        case view(ViewAction)
        case feedItemsUpdated([AccountFeedItem])
        case intervalUpdated(DateInterval?)
        case isLoadingUpdated(Bool)

        public enum ViewAction {
            case task
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
            case .isLoadingUpdated(let flag):
                state.isLoading = flag
                return .none
            default:
                return .none
            }
        }
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
        } catch: { error, send in
            
        }
    }
}
