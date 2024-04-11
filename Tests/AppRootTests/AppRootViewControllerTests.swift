import XCTest
import Foundation
import SnapshotTesting
@testable import AppRoot
import ComposableArchitecture
import APIClient
import Models
import UIKit

final class AppRootViewControllerTests: XCTestCase {
    func testSnapshotDataLoad() {
        let state = AppRoot.State(mode: .dataLoad(.init()))
        let store = StoreOf<AppRoot>(initialState: state, reducer: AppRoot.init) {
            $0[APIClient.self].getAccounts = { @Sendable in [] }
        }
        let vc = AppRootViewController(store: store)
        assertSnapshot(of: vc, as: .image)
    }

    func testSnapshotAccountList() {
        let account = Account.init(
            accountID: UUID(),
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Personal",
            currency: "GBP"
        )
        let state = AppRoot.State(mode: .accountList(.init(accounts: [account])))
        let store = StoreOf<AppRoot>(initialState: state, reducer: AppRoot.init) {
            $0[APIClient.self].getAccounts = { @Sendable in [] }
        }
        let vc = AppRootViewController(store: store)
        assertSnapshot(of: vc, as: .image)
    }
}
