import XCTest
import ComposableArchitecture
@testable import DataLoad
import APIClient

final class DataLoadTests: XCTestCase {
    @MainActor
    func testTaskSuccess() async throws {
        let testAccounts: [Account] = [
            .init(
                accountID: "accountID",
                accountType: .primary,
                defaultCategory: "defaultCategory",
                createdAt: Date(),
                name: "name"
            )
        ]
        let store = TestStore(
            initialState: DataLoad.State(),
            reducer: DataLoad.init
        ) {
            $0[APIClient.self].overrideGetAccounts(
                with: testAccounts,
                throwing: nil
            )
        }

        await store.send(.view(.task)) {
            $0.isLoadingData = true
        }
        
        await store.receive(\.isLoadingDataUpdated, false) {
            $0.isLoadingData = false
        }

        await store.receive(\.delegate.accountsUpdated, testAccounts)
    }

    @MainActor
    func testTaskFailure() async throws {
        let error = NSError(domain: "task", code: 1)
        let store = TestStore(
            initialState: DataLoad.State(),
            reducer: DataLoad.init
        ) {
            $0[APIClient.self].overrideGetAccounts(
                with: [],
                throwing: error as Error
            )
        }
        
        await store.send(.view(.task)) {
            $0.isLoadingData = true
        }
        
        await store.receive(\.errorMessageUpdated) {
            $0.errorMessage = error.localizedDescription
        }

        await store.receive(\.isLoadingDataUpdated, false) {
            $0.isLoadingData = false
        }
    }
}
