import Foundation
import ComposableArchitecture
import Models

@DependencyClient
public struct APIClient {
    public var getAccounts: @Sendable () async throws -> [Account]
    public var getAccountFeed: @Sendable (_ accountID: String, _ categoryID: String, _ interval: DateInterval) async throws -> [AccountFeedItem]
    public var getSavingsGoals: @Sendable (_ accountID: String) async throws -> [SavingsGoal]
    public var createSavingsGoal: @Sendable (_ accountID: String, _ name: String, _ currency: String) async throws -> SavingsGoal
    public var transferToSavingsGoal: @Sendable (_ accountID: String, _ savingsGoalID: String, _ amount: CurrencyAndAmount) async throws -> Bool
}

extension APIClient: DependencyKey {
    public static var testValue: APIClient = .init()
    public static var previewValue: APIClient = .init {
        [
            .init(
                accountID: UUID(),
                accountType: .primary,
                defaultCategory: "defaultCategory",
                createdAt: Date(),
                name: "Phan Anh Tran"
            ),
            .init(
                accountID: UUID(),
                accountType: .additional,
                defaultCategory: "defaultCategory",
                createdAt: Date(),
                name: "Phuong Nhung Nguyen"
            )
        ]
    } getAccountFeed: { accountID, categoryID, interval in
        [
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
    } getSavingsGoals: { accountID in
        []
    } createSavingsGoal: { _, _, _ in
        SavingsGoal(id: UUID())
    } transferToSavingsGoal: { _, _, _ in
        true
    }

    public static var liveValue: APIClient = .live
}

#if DEBUG
import XCTestDebugSupport

extension APIClient {
    public mutating func overrideGetAccounts(
        with accounts: [Account],
        throwing error: Error? = nil
    ) {
        let fulfill = expectation(description: "getAccountsAPI Called")
        self.getAccounts = {
            fulfill()
            if let error {
                throw error
            }
            return accounts
        }
    }

    public mutating func overrideGetAccountFeed(
        accountID: String,
        categoryID: String,
        interval: DateInterval,
        response: [AccountFeedItem],
        throwing error: Error? = nil
    ) {
        let fulfill = expectation(description: "getAccountFeedAPI Called")
        self.getAccountFeed = { @Sendable [self] requestAccountID, requestCategoryID, requestInterval in
            guard 
                requestAccountID == accountID,
                requestCategoryID == categoryID,
                requestInterval == interval
            else {
                return try await self.getAccountFeed(accountID: requestAccountID, categoryID: requestCategoryID, interval: requestInterval)
            }
            fulfill()
            if let error {
                throw error
            }
            return response
        }
    }
    
    public mutating func overrideGetSavingsGoals(
        accountID: String,
        response: [SavingsGoal],
        throwing error: Error? = nil
    ) {
        let fulfill = expectation(description: "getSavingsGoalsAPI Called")
        self.getSavingsGoals = { @Sendable [self] requestAccountID in
            guard
                requestAccountID == accountID
            else {
                return try await self.getSavingsGoals(accountID: requestAccountID)
            }
            fulfill()
            if let error {
                throw error
            }
            return response
        }
    }

    public mutating func overrideCreateSavingsGoal(
        accountID: String,
        name: String,
        currency: String,
        response: SavingsGoal,
        throwing error: Error? = nil
    ) {
        let fulfill = expectation(description: "createSavingsGoalAPI Called")
        self.createSavingsGoal = { @Sendable [self] requestAccountID, requestName, requestCurrency in
            guard
                requestAccountID == accountID,
                requestName == name,
                requestCurrency == currency
            else {
                return try await self.createSavingsGoal(accountID: requestAccountID, name: requestName, currency: requestCurrency)
            }
            fulfill()
            if let error {
                throw error
            }
            return response
        }
    }

    public mutating func overrideTransferToSavingsGoal(
        accountID: String,
        savingsGoalID: String,
        amount: CurrencyAndAmount,
        response: Bool,
        throwing error: Error? = nil
    ) {
        let fulfill = expectation(description: "transferToSavingsGoalAPI Called")
        self.transferToSavingsGoal = { @Sendable [self] requestAccountID, requestSavingsGoalID, requestAmount in
            guard
                requestAccountID == accountID,
                requestSavingsGoalID == savingsGoalID,
                requestAmount == amount
            else {
                return try await self.transferToSavingsGoal(accountID: requestAccountID, savingsGoalID: requestSavingsGoalID, amount: requestAmount)
            }
            fulfill()
            if let error {
                throw error
            }
            return response
        }
    }
}
#endif
