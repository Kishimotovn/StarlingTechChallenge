import XCTest
import Foundation
import SnapshotTesting
@testable import DataLoad
import ComposableArchitecture
import APIClient
import Models

final class DataLoadViewControllerTests: XCTestCase {
    func testSnapshotLoaded() {
        let state = DataLoad.State(isLoadingData: false, errorMessage: nil)
        let store = StoreOf<DataLoad>(initialState: state, reducer: DataLoad.init) {
            $0[APIClient.self].getAccounts = { @Sendable in [] }
        }
        let vc = DataLoadViewController(store: store)
        assertSnapshot(of: vc, as: .image)
    }

    func testSnapshotLoading() {
        let state = DataLoad.State(isLoadingData: true)
        let store = StoreOf<DataLoad>(initialState: state, reducer: DataLoad.init) {
            $0[APIClient.self].getAccounts = { @Sendable in [] }
        }
        let vc = DataLoadViewController(store: store)
        assertSnapshot(of: vc, as: .image)
    }
    
    func testSnapshotErrorMessage() {
        let state = DataLoad.State(errorMessage: "Some Error Message")
        let store = StoreOf<DataLoad>(initialState: state, reducer: DataLoad.init) {
            $0[APIClient.self].getAccounts = { @Sendable in [] }
        }
        let vc = DataLoadViewController(store: store)
        assertSnapshot(of: vc, as: .image)
    }
}
