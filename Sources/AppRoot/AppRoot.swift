import Foundation
import ComposableArchitecture
import DataLoad

@Reducer
public struct AppRoot {

    @ObservableState
    public struct State: Equatable {
        var mode: Mode.State

        public init(mode: Mode.State = .dataLoad(.init())) {
            self.mode = mode
        }
    }

    public enum Action {
        case mode(Mode.Action)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Scope(state: \.mode, action: \.mode) { Mode() }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .mode(.dataLoad(.delegate(.accountsUpdated(let accounts)))):
                
                print("got accounts", accounts)
//                state.mode = .accounts(accounts)
                return .none
            case .mode:
                return .none
            }
        }
    }
}
