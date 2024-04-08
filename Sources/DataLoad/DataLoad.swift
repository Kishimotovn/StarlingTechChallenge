import Foundation
import ComposableArchitecture
import APIClient

@Reducer
public struct DataLoad {
    @ObservableState
    public struct State: Equatable {
        var errorMessage: String?
        var isLoadingData: Bool = false

        public init() { 
            
        }
    }

    public enum Action: ViewAction {
        case view(ViewAction)
        case delegate(Delegate)
        
        case isLoadingDataUpdated(Bool)
        case errorMessageUpdated(String)
        
        @CasePathable public enum ViewAction {
            case task
        }
    
        @CasePathable public enum Delegate {
            case accountsUpdated([Account])
        }
    }

    public init() { }
    
    @Dependency(APIClient.self) var apiClient

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .view(.task):
                state.isLoadingData = true
                return .run { send in
                    let accounts = try await apiClient.getAccounts()
                    await send(.isLoadingDataUpdated(false))
                    await send(.delegate(.accountsUpdated(accounts)))
                } catch: { error, send in
                    await send(.errorMessageUpdated(error.localizedDescription))
                    await send(.isLoadingDataUpdated(false))
                }
            case .errorMessageUpdated(let message):
                state.errorMessage = message
                return .none
            case .isLoadingDataUpdated(let flag):
                state.isLoadingData = flag
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
