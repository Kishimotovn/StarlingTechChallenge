import Foundation
import SwiftUI
import ComposableArchitecture
import DataLoad
import AccountList

public struct AppRootView: View {
    let store: StoreOf<AppRoot>
    
    public init(store: StoreOf<AppRoot>) {
        self.store = store
    }

    public var body: some View {
        switch store.mode {
        case .dataLoad:
            if let store = store.scope(state: \.mode.dataLoad, action: \.mode.dataLoad) {
                DataLoadView(store: store)
            }
        case .accountList:
            if let store = store.scope(state: \.mode.accountList, action: \.mode.accountList) {
                AccountListView(store: store)
            }
        }
    }
}
