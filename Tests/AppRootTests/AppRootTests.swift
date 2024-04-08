import XCTest
import ComposableArchitecture
@testable import AppRoot
import Models

final class AppRootTests: XCTestCase {
    @MainActor
    func testDataLoadDelegateAccountsUpdated() async throws {
        let store = TestStore(
            initialState: AppRoot.State(mode: .dataLoad(.init())),
            reducer: AppRoot.init
        )
        
        let accounts: [Account] = [
            .init(
                accountID: UUID(),
                accountType: .primary,
                defaultCategory: "defaultCategory",
                createdAt: Date(),
                name: "account1"
            ),
            .init(
                accountID: UUID(),
                accountType: .primary,
                defaultCategory: "defaultCategory",
                createdAt: Date(),
                name: "account2"
            )
        ]

        await store.send(.mode(.dataLoad(.delegate(.accountsUpdated(accounts))))) {
            $0.mode = .accountList(.init(accounts: accounts))
        }
    }
}
