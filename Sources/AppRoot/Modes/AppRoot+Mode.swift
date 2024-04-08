import Foundation
import ComposableArchitecture
import DataLoad
import AccountList

public extension AppRoot {
    @Reducer struct Mode {
        @ObservableState
        public enum State: Equatable {
            case dataLoad(DataLoad.State)
            case accountList(AccountList.State)
        }

        public enum Action {
            case dataLoad(DataLoad.Action)
            case accountList(AccountList.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.dataLoad, action: \.dataLoad) { DataLoad() }
            Scope(state: \.accountList, action: \.accountList) { AccountList() }
        }
    }
}
