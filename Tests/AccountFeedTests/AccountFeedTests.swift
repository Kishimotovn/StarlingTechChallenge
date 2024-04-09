import Foundation
import Utils
import XCTest
@testable import AccountFeed
import Models
import ComposableArchitecture
import APIClient
import OrderedCollections

final class AccountFeedTests: XCTestCase {
    @MainActor
    func testHandleRoundUpWithErrorWhenTransaferringToSavingsGoal() async throws {
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let goal = SavingsGoal(id: UUID())
        let feedItems: [AccountFeedItem] = [
            .init(
                id: UUID(),
                direction: .outbound,
                reference: "feedItem1",
                amount: .init(currency: account.currency, minorUnits: 435),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            ),
            .init(
                id: UUID(),
                direction: .outbound,
                reference: "feedItem2",
                amount: .init(currency: account.currency, minorUnits: 520),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            ),
            .init(
                id: UUID(),
                direction: .outbound,
                reference: "feedItem3",
                amount: .init(currency: account.currency, minorUnits: 087),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            ),
            .init(
                id: UUID(),
                direction: .inbound,
                reference: "feedItem4",
                amount: .init(currency: account.currency, minorUnits: 123),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            )
        ]
        
        let expectedRoundUpAmount = CurrencyAndAmount(currency: account.currency, minorUnits: 158)
        
        let now = Date()
        let nextWeek = now.addingTimeInterval(60*60*24*7).startOfWeek()!
        let interval = DateInterval(start: nextWeek, duration: 60*60*24*7)
        
        let error = AppError(.unknown)
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                alert: nil,
                interval: interval,
                feedItems: feedItems
            ),
            reducer: AccountFeed.init
        ) { dependencies in
            dependencies[APIClient.self].overrideGetSavingsGoals(
                accountID: uuid.uuidString,
                response: [goal]
            )
            dependencies[APIClient.self].overrideTransferToSavingsGoal(
                accountID: account.id.uuidString,
                savingsGoalID: goal.id.uuidString,
                amount: expectedRoundUpAmount,
                response: true,
                throwing: error
            )
        }
        
        await store.send(.view(.roundUpTapped)) {
            $0.isRoundingUp = true
        }
        
        let roundUpRequest = AccountFeed.State.RoundUpSavingsRequest(goal: goal, amount: expectedRoundUpAmount)
        
        await store.receive(\.alertUpdated) {
            $0.alert = .init {
                TextState("Notice!")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
                ButtonState(action: .sendRoundUpAmountToSavingsGoal(request: roundUpRequest)) {
                    TextState("Confirm")
                }
            } message: {
                TextState("You are about to send this amount \(roundUpRequest.amount.description) to your savings goal.")
            }
        }
        
        await store.send(.alert(.presented(.sendRoundUpAmountToSavingsGoal(request: roundUpRequest)))) {
            $0.alert = nil
        }
        await store.receive(\.apiErrorsUpdated, .init([error.localizedDescription])) {
            $0.apiErrors = .init([error.localizedDescription])
            $0.alert = .init {
                TextState("Error")
            } actions: {
                ButtonState(action: .apiError(message: error.localizedDescription)) {
                    TextState("Ok")
                }
            } message: {
                TextState(error.localizedDescription)
            }
        }
        await store.receive(\.isRoundingUpdated, false) {
            $0.isRoundingUp = false
        }
    }

    @MainActor
    func testHandleRoundUpWithErrorWhenCreatingSavingsGoal() async throws {
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let goal = SavingsGoal(id: UUID())
        let error = AppError(.unknown)
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                apiErrors: .init()
            ),
            reducer: AccountFeed.init
        ) { dependencies in
            dependencies[APIClient.self].overrideGetSavingsGoals(
                accountID: uuid.uuidString,
                response: []
            )
            dependencies[APIClient.self].overrideCreateSavingsGoal(
                accountID: account.id.uuidString,
                name: "Tech Challenge Round Up!",
                currency: account.currency,
                response: goal,
                throwing: error
            )
        }
        
        await store.send(.view(.roundUpTapped)) {
            $0.isRoundingUp = true
        }
        
        await store.receive(\.alertUpdated) {
            $0.alert = .init {
                TextState("Notice!")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
                ButtonState(action: .savingsAccountCreationRequired) {
                    TextState("Confirm")
                }
            } message: {
                TextState("You don't have a current savings account, do you want to proceed to create one?")
            }
        }
        
        await store.send(.alert(.presented(.savingsAccountCreationRequired))) {
            $0.alert = nil
        }
        
        await store.receive(\.apiErrorsUpdated, .init([error.localizedDescription])) {
            $0.apiErrors = .init([error.localizedDescription])
            $0.alert = .init {
                TextState("Error")
            } actions: {
                ButtonState(action: .apiError(message: error.localizedDescription)) {
                    TextState("Ok")
                }
            } message: {
                TextState(error.localizedDescription)
            }
        }
        await store.receive(\.isRoundingUpdated, false) {
            $0.isRoundingUp = false
        }
    }

    @MainActor
    func testHandleRoundUpWithErrorWhenFetchingSavingsGoals() async throws {
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        
        let error = AppError(.unknown)
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                apiErrors: .init()
            ),
            reducer: AccountFeed.init
        ) { dependencies in
            dependencies[APIClient.self].overrideGetSavingsGoals(
                accountID: uuid.uuidString,
                response: [],
                throwing: error
            )
        }
        
        await store.send(.view(.roundUpTapped)) {
            $0.isRoundingUp = true
        }
        await store.receive(\.apiErrorsUpdated, .init([error.localizedDescription])) {
            $0.apiErrors = .init([error.localizedDescription])
            $0.alert = .init {
                TextState("Error")
            } actions: {
                ButtonState(action: .apiError(message: error.localizedDescription)) {
                    TextState("Ok")
                }
            } message: {
                TextState(error.localizedDescription)
            }
        }
        await store.receive(\.isRoundingUpdated, false) {
            $0.isRoundingUp = false
        }
    }

    @MainActor
    func testDismissingAlertShouldSetIsRoundingUpToFalseIfNeeded() async throws {
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        
        let alert = AlertState<AccountFeed.Action.Alert>.init {
            TextState("Any Alert")
        } actions: {
            ButtonState {
                TextState("Dismiss")
            }
        }
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                alert: alert,
                isRoundingUp: false
            ),
            reducer: AccountFeed.init
        )
        
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }
        
        await store.send(.isRoundingUpdated(true)) {
            $0.isRoundingUp = true
        }
        
        await store.send(.alertUpdated(alert)) {
            $0.alert = alert
        }
        
        await store.send(.alert(.dismiss)) {
            $0.alert = nil
            $0.isRoundingUp = false
        }
    }

    @MainActor
    func testHandleRoundUpWithExistingSavingGoal() async throws {
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let goal = SavingsGoal(id: UUID())
        let feedItems: [AccountFeedItem] = [
            .init(
                id: UUID(),
                direction: .outbound,
                reference: "feedItem1",
                amount: .init(currency: account.currency, minorUnits: 435),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            ),
            .init(
                id: UUID(),
                direction: .outbound,
                reference: "feedItem2",
                amount: .init(currency: account.currency, minorUnits: 520),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            ),
            .init(
                id: UUID(),
                direction: .outbound,
                reference: "feedItem3",
                amount: .init(currency: account.currency, minorUnits: 087),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            ),
            .init(
                id: UUID(),
                direction: .inbound,
                reference: "feedItem4",
                amount: .init(currency: account.currency, minorUnits: 123),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            )
        ]
        
        let expectedRoundUpAmount = CurrencyAndAmount(currency: account.currency, minorUnits: 158)
        
        let now = Date()
        let nextWeek = now.addingTimeInterval(60*60*24*7).startOfWeek()!
        let interval = DateInterval(start: nextWeek, duration: 60*60*24*7)
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                alert: nil,
                interval: interval,
                feedItems: feedItems
            ),
            reducer: AccountFeed.init
        ) { dependencies in
            dependencies[APIClient.self].overrideGetSavingsGoals(
                accountID: uuid.uuidString,
                response: [goal]
            )
            dependencies[APIClient.self].overrideTransferToSavingsGoal(
                accountID: account.id.uuidString,
                savingsGoalID: goal.id.uuidString,
                amount: expectedRoundUpAmount,
                response: true
            )
            dependencies[APIClient.self].overrideGetAccountFeed(
                accountID: account.id.uuidString,
                categoryID: account.defaultCategory,
                interval: interval,
                response: feedItems
            )
        }
        
        await store.send(.view(.roundUpTapped)) {
            $0.isRoundingUp = true
        }
        
        let roundUpRequest = AccountFeed.State.RoundUpSavingsRequest(goal: goal, amount: expectedRoundUpAmount)
        
        await store.receive(\.alertUpdated) {
            $0.alert = .init {
                TextState("Notice!")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
                ButtonState(action: .sendRoundUpAmountToSavingsGoal(request: roundUpRequest)) {
                    TextState("Confirm")
                }
            } message: {
                TextState("You are about to send this amount \(roundUpRequest.amount.description) to your savings goal.")
            }
        }
        
        await store.send(.alert(.presented(.sendRoundUpAmountToSavingsGoal(request: roundUpRequest)))) {
            $0.alert = nil
        }
        await store.receive(\.alertUpdated) {
            $0.alert = .init {
                TextState("Notice!")
            } actions: {
                ButtonState(action: .refreshFeed) {
                    TextState("Got it!")
                }
            } message: {
                TextState("Successfully sent \(roundUpRequest.amount.description) to your savings goal.")
            }
        }
        await store.receive(\.isRoundingUpdated, false) {
            $0.isRoundingUp = false
        }
        
        await store.send(.alert(.presented(.refreshFeed))) {
            $0.alert = nil
            $0.isLoading = true
        }
        await store.receive(\.feedItemsUpdated, feedItems)
        await store.receive(\.intervalUpdated, interval)
        await store.receive(\.isLoadingUpdated, false) {
            $0.isLoading = false
        }
    }

    @MainActor
    func testHandleRoundUpWithoutExistingSavingGoal() async throws {
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let goal = SavingsGoal(id: UUID())
        let feedItems: [AccountFeedItem] = [
            .init(
                id: UUID(),
                direction: .outbound,
                reference: "feedItem1",
                amount: .init(currency: account.currency, minorUnits: 435),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            ),
            .init(
                id: UUID(),
                direction: .outbound,
                reference: "feedItem2",
                amount: .init(currency: account.currency, minorUnits: 520),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            ),
            .init(
                id: UUID(),
                direction: .outbound,
                reference: "feedItem3",
                amount: .init(currency: account.currency, minorUnits: 087),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            ),
            .init(
                id: UUID(),
                direction: .inbound,
                reference: "feedItem4",
                amount: .init(currency: account.currency, minorUnits: 123),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            )
        ]
        
        let expectedRoundUpAmount = CurrencyAndAmount(currency: account.currency, minorUnits: 158)
        
        let now = Date()
        let nextWeek = now.addingTimeInterval(60*60*24*7).startOfWeek()!
        let interval = DateInterval(start: nextWeek, duration: 60*60*24*7)
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                alert: nil,
                interval: interval,
                feedItems: feedItems
            ),
            reducer: AccountFeed.init
        ) { dependencies in
            dependencies[APIClient.self].overrideGetSavingsGoals(
                accountID: uuid.uuidString,
                response: []
            )
            dependencies[APIClient.self].overrideCreateSavingsGoal(
                accountID: account.id.uuidString,
                name: "Tech Challenge Round Up!",
                currency: account.currency,
                response: goal
            )
            dependencies[APIClient.self].overrideTransferToSavingsGoal(
                accountID: account.id.uuidString,
                savingsGoalID: goal.id.uuidString,
                amount: expectedRoundUpAmount,
                response: true
            )
            dependencies[APIClient.self].overrideGetAccountFeed(
                accountID: account.id.uuidString,
                categoryID: account.defaultCategory,
                interval: interval,
                response: feedItems
            )
        }
        
        await store.send(.view(.roundUpTapped)) {
            $0.isRoundingUp = true
        }
        await store.receive(\.alertUpdated) {
            $0.alert = .init {
                TextState("Notice!")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
                ButtonState(action: .savingsAccountCreationRequired) {
                    TextState("Confirm")
                }
            } message: {
                TextState("You don't have a current savings account, do you want to proceed to create one?")
            }
        }

        let roundUpRequest = AccountFeed.State.RoundUpSavingsRequest(goal: goal, amount: expectedRoundUpAmount)

        await store.send(.alert(.presented(.savingsAccountCreationRequired))) {
            $0.alert = nil
        }
        await store.receive(\.alertUpdated) {
            $0.alert = .init {
                TextState("Notice!")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
                ButtonState(action: .sendRoundUpAmountToSavingsGoal(request: roundUpRequest)) {
                    TextState("Confirm")
                }
            } message: {
                TextState("You are about to send this amount \(roundUpRequest.amount.description) to your savings goal.")
            }
        }

        await store.send(.alert(.presented(.sendRoundUpAmountToSavingsGoal(request: roundUpRequest)))) {
            $0.alert = nil
        }
        await store.receive(\.alertUpdated) {
            $0.alert = .init {
                TextState("Notice!")
            } actions: {
                ButtonState(action: .refreshFeed) {
                    TextState("Got it!")
                }
            } message: {
                TextState("Successfully sent \(roundUpRequest.amount.description) to your savings goal.")
            }
        }
        await store.receive(\.isRoundingUpdated, false) {
            $0.isRoundingUp = false
        }

        await store.send(.alert(.presented(.refreshFeed))) {
            $0.alert = nil
            $0.isLoading = true
        }
        await store.receive(\.feedItemsUpdated, feedItems)
        await store.receive(\.intervalUpdated, interval)
        await store.receive(\.isLoadingUpdated, false) {
            $0.isLoading = false
        }
    }

    @MainActor
    func testViewTaskSuccess() async throws {
        let now = Date()
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let startOfWeek = now.startOfWeek()!
        let dateInterval = DateInterval(start: startOfWeek, duration: .oneWeek)
        let feedItems: [AccountFeedItem] = [
            .init(
                id: UUID(),
                direction: .inbound,
                reference: "reference",
                amount: nil,
                source: nil,
                transactionTime: nil
            )
        ]

        let store = TestStore(
            initialState: AccountFeed.State(account: account),
            reducer: AccountFeed.init
        ) {
            $0[APIClient.self].overrideGetAccountFeed(
                accountID: account.id.uuidString,
                categoryID: account.defaultCategory,
                interval: dateInterval,
                response: feedItems
            )
            $0.date = .constant(now)
        }
        
        await store.send(.view(.task)) {
            $0.isLoading = true
        }
        
        await store.receive(\.feedItemsUpdated, feedItems) {
            $0.feedItems = .init(uniqueElements: feedItems)
        }
        await store.receive(\.intervalUpdated, dateInterval) {
            $0.interval = dateInterval
        }
        await store.receive(\.isLoadingUpdated, false) {
            $0.isLoading = false
        }
    }
    
    @MainActor
    func testNextWeekFeedRequestedIsCancelledIfIntervalIsNotSet() async throws {
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                interval: nil,
                isLoading: false
            ),
            reducer: AccountFeed.init
        )
        
        await store.send(.view(.nextWeekTapped))
    }
    
    @MainActor
    func testNextWeekFeedRequestedIsCancelledIfIsLoading() async throws {
        let now = Date()
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let startOfWeek = now.startOfWeek()!
        let dateIntervalOfCurrentWeek = DateInterval(start: startOfWeek, duration: .oneWeek)
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                interval: dateIntervalOfCurrentWeek,
                isLoading: true
            ),
            reducer: AccountFeed.init
        )
        
        await store.send(.view(.nextWeekTapped))
    }
    
    @MainActor
    func testNextWeekFeedRequested() async throws {
        let now = Date()
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let startOfWeek = now.startOfWeek()!
        let dateIntervalOfCurrentWeek = DateInterval(start: startOfWeek, duration: .oneWeek)
        let feedItems: [AccountFeedItem] = [
            .init(
                id: UUID(),
                direction: .inbound,
                reference: "reference",
                amount: nil,
                source: nil,
                transactionTime: nil
            )
        ]
        
        let startOfNextWeek = startOfWeek.addingTimeInterval(.oneWeek)
        let dateIntervalIOfNextWeek = DateInterval(start: startOfNextWeek, duration: .oneWeek)
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                interval: dateIntervalOfCurrentWeek,
                isLoading: false
            ),
            reducer: AccountFeed.init
        ) {
            $0[APIClient.self].overrideGetAccountFeed(
                accountID: account.id.uuidString,
                categoryID: account.defaultCategory,
                interval: dateIntervalIOfNextWeek,
                response: feedItems
            )
            $0.date = .constant(now)
        }
        
        await store.send(.view(.nextWeekTapped)) {
            $0.isLoading = true
        }
        
        await store.receive(\.feedItemsUpdated, feedItems) {
            $0.feedItems = .init(uniqueElements: feedItems)
        }
        await store.receive(\.intervalUpdated, dateIntervalIOfNextWeek) {
            $0.interval = dateIntervalIOfNextWeek
        }
        await store.receive(\.isLoadingUpdated, false) {
            $0.isLoading = false
        }
    }
    
    @MainActor
    func testPrevWeekFeedRequestedIsCancelledIfIntervalIsNotSet() async throws {
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                interval: nil,
                isLoading: false
            ),
            reducer: AccountFeed.init
        )
        
        await store.send(.view(.prevWeekTapped))
    }
    
    @MainActor
    func testPrevWeekFeedRequestedIsCancelledIfIsLoading() async throws {
        let now = Date()
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let startOfWeek = now.startOfWeek()!
        let dateIntervalOfCurrentWeek = DateInterval(start: startOfWeek, duration: .oneWeek)
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                interval: dateIntervalOfCurrentWeek,
                isLoading: true
            ),
            reducer: AccountFeed.init
        )
        
        await store.send(.view(.prevWeekTapped))
    }
    
    @MainActor
    func testPrevWeekFeedRequested() async throws {
        let now = Date()
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let startOfWeek = now.startOfWeek()!
        let dateIntervalOfCurrentWeek = DateInterval(start: startOfWeek, duration: .oneWeek)
        let feedItems: [AccountFeedItem] = [
            .init(
                id: UUID(),
                direction: .inbound,
                reference: "reference",
                amount: nil,
                source: nil,
                transactionTime: nil
            )
        ]
        
        let startOfPrevWeek = startOfWeek.addingTimeInterval(-.oneWeek)
        let dateIntervalIOfPrevWeek = DateInterval(start: startOfPrevWeek, duration: .oneWeek)
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                interval: dateIntervalOfCurrentWeek,
                isLoading: false
            ),
            reducer: AccountFeed.init
        ) {
            $0[APIClient.self].overrideGetAccountFeed(
                accountID: account.id.uuidString,
                categoryID: account.defaultCategory,
                interval: dateIntervalIOfPrevWeek,
                response: feedItems
            )
            $0.date = .constant(now)
        }
        
        await store.send(.view(.prevWeekTapped)) {
            $0.isLoading = true
        }
        
        await store.receive(\.feedItemsUpdated, feedItems) {
            $0.feedItems = .init(uniqueElements: feedItems)
        }
        await store.receive(\.intervalUpdated, dateIntervalIOfPrevWeek) {
            $0.interval = dateIntervalIOfPrevWeek
        }
        await store.receive(\.isLoadingUpdated, false) {
            $0.isLoading = false
        }
    }
    
    @MainActor
    func testViewTaskError() async throws {
        let now = Date()
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let startOfWeek = now.startOfWeek()!
        let dateInterval = DateInterval(start: startOfWeek, duration: .oneWeek)
        let feedItems: [AccountFeedItem] = []
        
        let error = AppError(.unknown)

        let store = TestStore(
            initialState: AccountFeed.State(account: account),
            reducer: AccountFeed.init
        ) {
            $0[APIClient.self].overrideGetAccountFeed(
                accountID: account.id.uuidString,
                categoryID: account.defaultCategory,
                interval: dateInterval,
                response: feedItems,
                throwing: error
            )
            $0.date = .constant(now)
        }
        
        await store.send(.view(.task)) {
            $0.isLoading = true
        }
        await store.receive(\.apiErrorsUpdated, .init([error.localizedDescription])) {
            $0.apiErrors = .init([error.localizedDescription])
            $0.alert = AlertState {
                TextState("Error")
            } actions: {
                ButtonState(action: .apiError(message: error.localizedDescription)) {
                    TextState("Ok")
                }
            } message: {
                TextState(error.localizedDescription)
            }
        }
        await store.receive(\.isLoadingUpdated, false) {
            $0.isLoading = false
        }
        
        await store.send(.alert(.presented(.apiError(message: error.localizedDescription)))) {
            $0.apiErrors = .init()
            $0.alert = nil
        }
    }
    
    @MainActor
    func testShouldAlertNextErrorsIfNeeded() async throws {
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let error = AppError(.unknown)
        let error2 = NSError(domain: "domain", code: 1)
        let errors = OrderedSet<String>([error.localizedDescription, error2.localizedDescription])
        let initialAlert = AlertState {
            TextState("Error")
        } actions: {
            ButtonState(action: AccountFeed.Action.Alert.apiError(message: error.localizedDescription)) {
                TextState("Ok")
            }
        } message: {
            TextState(error.localizedDescription)
        }
        
        let store = TestStore(
            initialState: AccountFeed.State(
                account: account,
                apiErrors: errors,
                alert: initialAlert
            ),
            reducer: AccountFeed.init
        )
        
        await store.send(.alert(.presented(.apiError(message: error.localizedDescription)))) {
            $0.apiErrors = .init([error2.localizedDescription])
            $0.alert = AlertState {
                TextState("Error")
            } actions: {
                ButtonState(action: .apiError(message: error2.localizedDescription)) {
                    TextState("Ok")
                }
            } message: {
                TextState(error2.localizedDescription)
            }
        }
        
        await store.send(.alert(.presented(.apiError(message: error2.localizedDescription)))) {
            $0.apiErrors = .init()
            $0.alert = nil
        }
    }
}
