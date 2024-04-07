import Foundation
import ComposableArchitecture

@Reducer
public struct AppRoot {
    public struct State: Equatable { 
        public init() { }
    }
    
    public enum Action {
        
    }

    public init() { }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
