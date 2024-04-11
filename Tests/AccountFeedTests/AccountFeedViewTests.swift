import XCTest
import Foundation
import SnapshotTesting
@testable import AccountFeed
import ComposableArchitecture
import APIClient
import Models
import UIKit
import SwiftUI

final class AccountFeedViewTests: XCTestCase {
    func testSnapshotFeedNormal() {
        let account = Account.init(
            accountID: UUID(),
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Personal",
            currency: "GBP"
        )
        let feedItems: [AccountFeedItem] = [
            AccountFeedItem(
                id: UUID(),
                direction: .inbound,
                reference: "Inbound Transaction",
                amount: .init(currency: "GBP", minorUnits: 1234),
                source: .fasterPaymentsIn,
                transactionTime: Date()
            ),
            AccountFeedItem(
                id: UUID(),
                direction: .outbound,
                reference: "Outbound Transaction",
                amount: .init(currency: "GBP", minorUnits: 9876),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            )
        ]
        let date = Date(isoDate: "2024-04-11")
        let interval = DateInterval(start: date, duration: .oneWeek)
        let state = AccountFeed.State(
            account: account,
            apiErrors: .init(),
            alert: nil,
            interval: interval,
            isLoading: false,
            feedItems: feedItems,
            isRoundingUp: false
        )
        let store = StoreOf<AccountFeed>(initialState: state, reducer: AccountFeed.init) {
            $0[APIClient.self].getAccounts = { @Sendable in [] }
            $0.date = .constant(date)
        }
        let view = AccountFeedView(store: store)
        let vc = UINavigationController(rootViewController: UIHostingController(rootView: view))
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
    
    func testSnapshotFeedLoading() {
        let account = Account.init(
            accountID: UUID(),
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Personal",
            currency: "GBP"
        )
        let feedItems: [AccountFeedItem] = [
            AccountFeedItem(
                id: UUID(),
                direction: .inbound,
                reference: "Inbound Transaction",
                amount: .init(currency: "GBP", minorUnits: 1234),
                source: .fasterPaymentsIn,
                transactionTime: Date()
            ),
            AccountFeedItem(
                id: UUID(),
                direction: .outbound,
                reference: "Outbound Transaction",
                amount: .init(currency: "GBP", minorUnits: 9876),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            )
        ]
        let date = Date(isoDate: "2024-04-11")
        let interval = DateInterval(start: date, duration: .oneWeek)
        let state = AccountFeed.State(
            account: account,
            apiErrors: .init(),
            alert: nil,
            interval: interval,
            isLoading: true,
            feedItems: feedItems,
            isRoundingUp: false
        )
        let store = StoreOf<AccountFeed>(initialState: state, reducer: AccountFeed.init) {
            $0[APIClient.self].getAccounts = { @Sendable in [] }
            $0.date = .constant(date)
        }
        let view = AccountFeedView(store: store)
        let vc = UINavigationController(rootViewController: UIHostingController(rootView: view))
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
    
    func testSnapshotNoRoundUpIfFeedIsEmpty() {
        let account = Account.init(
            accountID: UUID(),
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Personal",
            currency: "GBP"
        )
        let feedItems: [AccountFeedItem] = []
        let date = Date(isoDate: "2024-04-11")
        let interval = DateInterval(start: date, duration: .oneWeek)
        let state = AccountFeed.State(
            account: account,
            apiErrors: .init(),
            alert: nil,
            interval: interval,
            isLoading: false,
            feedItems: feedItems,
            isRoundingUp: false
        )
        let store = StoreOf<AccountFeed>(initialState: state, reducer: AccountFeed.init) {
            $0[APIClient.self].getAccounts = { @Sendable in [] }
            $0.date = .constant(date)
        }
        let view = AccountFeedView(store: store)
        let vc = UINavigationController(rootViewController: UIHostingController(rootView: view))
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
    
    func testSnapshotRoundingUp() {
        let account = Account.init(
            accountID: UUID(),
            accountType: .primary,
            defaultCategory: "defaultCategory",
            createdAt: Date(),
            name: "Personal",
            currency: "GBP"
        )
        let feedItems: [AccountFeedItem] = [
            AccountFeedItem(
                id: UUID(),
                direction: .inbound,
                reference: "Inbound Transaction",
                amount: .init(currency: "GBP", minorUnits: 1234),
                source: .fasterPaymentsIn,
                transactionTime: Date()
            ),
            AccountFeedItem(
                id: UUID(),
                direction: .outbound,
                reference: "Outbound Transaction",
                amount: .init(currency: "GBP", minorUnits: 9876),
                source: .fasterPaymentsOut,
                transactionTime: Date()
            )
        ]
        let date = Date(isoDate: "2024-04-11")
        let interval = DateInterval(start: date, duration: .oneWeek)
        let state = AccountFeed.State(
            account: account,
            apiErrors: .init(),
            alert: nil,
            interval: interval,
            isLoading: false,
            feedItems: feedItems,
            isRoundingUp: true
        )
        let store = StoreOf<AccountFeed>(initialState: state, reducer: AccountFeed.init) {
            $0[APIClient.self].getAccounts = { @Sendable in [] }
            $0.date = .constant(date)
        }
        let view = AccountFeedView(store: store)
        let vc = UINavigationController(rootViewController: UIHostingController(rootView: view))
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
}
