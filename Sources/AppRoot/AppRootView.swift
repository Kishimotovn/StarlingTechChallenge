import Foundation
import SwiftUI
import ComposableArchitecture

public struct AppRootView: View {
    let store: StoreOf<AppRoot>
    
    public init(store: StoreOf<AppRoot>) {
        self.store = store
    }

    public var body: some View {
        Text("Hello")
    }
}
