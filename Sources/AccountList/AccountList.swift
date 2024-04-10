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
        var acountFeedPaths: IdentifiedArrayOf<AccountFeed.State>
        var accounts: IdentifiedArrayOf<Account>

        public init(accounts: [Account]) {
            self.accounts = .init(uniqueElements: accounts)
            self.acountFeedPaths = .init(uniqueElements: accounts.map { AccountFeed.State.init(account: $0) })
        }
    }

    public enum Action {
        case path(StackAction<AccountFeed.State, AccountFeed.Action>)
        case acountFeedPaths(IdentifiedActionOf<AccountFeed>)
    }

    public init() { }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
            .forEach(\.path, action: \.path) {
                AccountFeed()
            }
            .forEach(\.acountFeedPaths, action: \.acountFeedPaths) {
                AccountFeed()
            }
    }
}
