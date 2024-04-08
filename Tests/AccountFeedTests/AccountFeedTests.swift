import Foundation
import XCTest
@testable import AccountFeed
import Models
import ComposableArchitecture
import APIClient

final class AccountFeedTests: XCTestCase {
    @MainActor
    func testViewTask() async throws {
        let now = Date()
        let uuid = UUID()
        let account = Account(
            accountID: uuid,
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Account Name"
        )
        let startOfWeek = now.startOfWeek()!
        let dateInterval = DateInterval(start: startOfWeek, duration: .oneWeek)
        let feedItems: [AccountFeedItem] = []

        let store = TestStore(
            initialState: AccountFeed.State(account: account),
            reducer: AccountFeed.init
        ) {
            $0[APIClient.self].overrideGetAccountFeed(
                accountID: account.id.uuidString,
                categoryID: account.defaultCategory,
                interval: dateInterval,
                response: feedItems
            )
            $0.date = .constant(now)
        }
        
        await store.send(.view(.task)) {
            $0.isLoading = true
        }
        
        await store.receive(\.feedItemsUpdated, feedItems)
        await store.receive(\.intervalUpdated, dateInterval)
        await store.receive(\.isLoadingUpdated, false) {
            $0.isLoading = false
        }
    }
}
