import Foundation
import ComposableArchitecture
import SwiftUI

public struct AccountFeedView: View {
    public let store: StoreOf<AccountFeed>
    
    public init(store: StoreOf<AccountFeed>) {
        self.store = store
    }

    public var body: some View {
        Text("Account Feed View for \(store.accountID)")
    }
}
