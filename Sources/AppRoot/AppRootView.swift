import Foundation
import SwiftUI
import ComposableArchitecture
import DataLoad

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
        }
    }
}
