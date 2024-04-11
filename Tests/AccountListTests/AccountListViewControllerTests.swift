import XCTest
import Foundation
import SnapshotTesting
@testable import AccountList
import ComposableArchitecture
import APIClient
import Models
import UIKit

final class AccountListViewControllerTests: XCTestCase {
    func testSnapshotListNormal() {
        let account = Account.init(
            accountID: UUID(),
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Personal",
            currency: "GBP"
        )
        let state = AccountList.State(accounts: [account])
        let store = StoreOf<AccountList>(initialState: state, reducer: AccountList.init) {
            $0[APIClient.self].getAccounts = { @Sendable in [] }
        }
        let vc = UINavigationController(rootViewController: AccountListViewController(store: store))
        assertSnapshot(of: vc, as: .image)
    }
}
