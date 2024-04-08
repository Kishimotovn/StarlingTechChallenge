import Foundation
import ComposableArchitecture
import SwiftUI

@ViewAction(for: DataLoad.self)
public struct DataLoadView: View {
    public let store: StoreOf<DataLoad>

    public init(store: StoreOf<DataLoad>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if store.isLoadingData {
                ProgressView()
            } else if let errorMessage = store.errorMessage {
                VStack {
                    Text("Error getting accounts information")
                    Text(errorMessage)
                    Text("Access token might be expired.")
                }
            } else {
                Text("Accounts data loaded.")
            }
        }
        .task {
            await send(.task).finish()
        }
    }
}
