import Foundation
import ComposableArchitecture
import DataLoad

public extension AppRoot {
    @Reducer struct Mode {
        @ObservableState
        public enum State: Equatable {
            case dataLoad(DataLoad.State)
        }

        public enum Action {
            case dataLoad(DataLoad.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.dataLoad, action: \.dataLoad) { DataLoad() }
        }
    }
}
