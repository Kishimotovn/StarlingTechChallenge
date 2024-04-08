import Foundation
import ComposableArchitecture
import AccountFeed
import APIClient
import Models

@Reducer
public struct AccountList {
    @ObservableState
    public struct State: Equatable {
        var path: StackState<AccountFeed.State> = .init()
        var accounts: IdentifiedArrayOf<Account>

        public init(accounts: [Account]) {
            self.accounts = .init(uniqueElements: accounts)
        }
    }

    public enum Action {
        case path(StackAction<AccountFeed.State, AccountFeed.Action>)
    }

    public init() { }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
            .forEach(\.path, action: \.path) {
                AccountFeed()
            }
    }
}
