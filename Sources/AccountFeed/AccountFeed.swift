import Foundation
import ComposableArchitecture

@Reducer
public struct AccountFeed {
    
    @ObservableState
    public struct State {
        var accountID: String

        public init(accountID: String) {
            self.accountID = accountID
        }
    }

    public init() { }
}
