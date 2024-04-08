import Foundation
import Models

struct GetAccountFeedOutput: Decodable {
    struct FeedItem: Decodable {
        let feedItemID: UUID?
        let categoryID: UUID?
        let amount: CurrencyAndAmount?
        let sourceAmount: CurrencyAndAmount?
        let direction: Direction?
        let updatedAt: Date?
        let transactionTime: Date?
        let settlementTime: Date?
        let retryAllocationUntilTime: Date?
        let source: Source?
        let sourceSubType: SourceSubType?
        let status: Status?
        let transactingApplicationUserID: String?
        let counterPartyType: CounterPartyType?
        let counterPartyID: UUID?
        let counterPartyName: String?
        let counterPartySubEntityID: UUID?
        let counterPartySubEntityName: String?
        let counterPartySubEntityIdentifier: String?
        let counterPartySubEntitySubIdentifier: String?
        let exchangeRate: Double?
        let totalFees: Double?
        let totalFeeAmount: CurrencyAndAmount?
        let reference: String?
        let country: String?
        let spendingCategory: String?
        let userNote: String?
        let roundUp: AssociatedFeedRoundUp?
        let hasAttachment: Bool?
        let hasReceipt: Bool?

        enum CodingKeys: String, CodingKey {
            case feedItemID = "feedItemUid"
            case categoryID = "categoryUid"
            case amount
            case sourceAmount
            case direction
            case updatedAt
            case transactionTime
            case settlementTime
            case retryAllocationUntilTime
            case source
            case sourceSubType
            case status
            case transactingApplicationUserID = "transactingApplicationUserUid"
            case counterPartyType
            case counterPartyID = "counterPartyUid"
            case counterPartyName
            case counterPartySubEntityID = "counterPartySubEntityUid"
            case counterPartySubEntityName
            case counterPartySubEntityIdentifier
            case counterPartySubEntitySubIdentifier
            case exchangeRate
            case totalFees
            case totalFeeAmount
            case reference
            case country
            case spendingCategory
            case userNote
            case roundUp
            case hasAttachment
            case hasReceipt
        }
    }
    
    let feedItems: [FeedItem]
}

extension AccountFeedItem {
    init?(item: GetAccountFeedOutput.FeedItem) {
        guard 
            let id = item.feedItemID,
            let direction = item.direction
        else {
            return nil
        }

        var source: Source? = nil
        if let rawSource = item.source {
            source = .init(source: rawSource)
        }

        self.init(
            id: id,
            direction: .init(direction: direction),
            reference: item.reference,
            amount: item.amount,
            source: source,
            transactionTime: item.transactionTime
        )
    }
}

// MARK: - Direction:
extension GetAccountFeedOutput.FeedItem {
    enum Direction: String, Decodable {
        case `in` = "IN"
        case out = "OUT"
    }
}

extension AccountFeedItem.Direction {
    init(direction: GetAccountFeedOutput.FeedItem.Direction) {
        switch direction {
        case .in:
            self = .inbound
        case .out:
            self = .outbound
        }
    }
}

// MARK: - AssociatedFeedRoundUp:
extension GetAccountFeedOutput.FeedItem {
    struct AssociatedFeedRoundUp: Decodable {
        let goalCategoryID: UUID?
        let amount: CurrencyAndAmount?

        enum CodingKeys: String, CodingKey {
            case goalCategoryID = "goalCategoryUid"
            case amount
        }
    }
}


// MARK: - CounterPartyType:
extension GetAccountFeedOutput.FeedItem {
    enum CounterPartyType: String, Decodable {
        case category = "CATEGORY"
        case cheque = "CHEQUE"
        case customer = "CUSTOMER"
        case payee = "PAYEE"
        case merchant = "MERCHANT"
        case sender = "SENDER"
        case starling = "STARLING"
        case loan = "LOAN"
    }
}

// MARK: - CurrencyAndAmount:
extension CurrencyAndAmount: Decodable {
    enum CodingKeys: String, CodingKey {
        case currency
        case minorUnits
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try container.decode(String.self, forKey: .currency)
        let minorUnits = try container.decode(Int.self, forKey: .minorUnits)
        self.init(currency: currency, minorUnits: minorUnits)
    }
}

// MARK: - Statuses:
extension GetAccountFeedOutput.FeedItem {
    enum Status: String, Decodable {
        case upcoming = "UPCOMING"
        case upcomingCancelled = "UPCOMING_CANCELLED"
        case pending = "PENDING"
        case reversed = "REVERSED"
        case settled = "SETTLED"
        case declined = "DECLINED"
        case refunded = "REFUNDED"
        case retrying = "RETRYING"
        case accountCheck = "ACCOUNT_CHECK"
    }
}

// MARK: - Source Types:
extension GetAccountFeedOutput.FeedItem {
    enum Source: String, Decodable {
        case britishBusinessBankFees = "BRITISH_BUSINESS_BANK_FEES"
        case cardFeeCharge = "CARD_FEE_CHARGE"
        case cashDeposit = "CASH_DEPOSIT"
        case cashDepositCharge = "CASH_DEPOSIT_CHARGE"
        case cashWithdrawal = "CASH_WITHDRAWAL"
        case cashWithdrawalCharge = "CASH_WITHDRAWAL_CHARGE"
        case chaps = "CHAPS"
        case cheque = "CHEQUE"
        case cicsCheque = "CICS_CHEQUE"
        case currencyCloud = "CURRENCY_CLOUD"
        case directCredit = "DIRECT_CREDIT"
        case directDebit = "DIRECT_DEBIT"
        case directDebitDispute = "DIRECT_DEBIT_DISPUTE"
        case internalTransfer = "INTERNAL_TRANSFER"
        case masterCard = "MASTER_CARD"
        case mastercardMoneysend = "MASTERCARD_MONEYSEND"
        case mastercardChargeback = "MASTERCARD_CHARGEBACK"
        case missedPaymentFee = "MISSED_PAYMENT_FEE"
        case fasterPaymentsIn = "FASTER_PAYMENTS_IN"
        case fasterPaymentsOut = "FASTER_PAYMENTS_OUT"
        case fasterPaymentsReversal = "FASTER_PAYMENTS_REVERSAL"
        case stripeFunding = "STRIPE_FUNDING"
        case interestPayment = "INTEREST_PAYMENT"
        case nostroDeposit = "NOSTRO_DEPOSIT"
        case overdraft = "OVERDRAFT"
        case overdraftInterestWaived = "OVERDRAFT_INTEREST_WAIVED"
        case fasterPaymentsRefund = "FASTER_PAYMENTS_REFUND"
        case starlingPayStripe = "STARLING_PAY_STRIPE"
        case onUsPayMe = "ON_US_PAY_ME"
        case loanPrincipalPayment = "LOAN_PRINCIPAL_PAYMENT"
        case loanRepayment = "LOAN_REPAYMENT"
        case loanOverpayment = "LOAN_OVERPAYMENT"
        case loanLatePayment = "LOAN_LATE_PAYMENT"
        case loanFeePayment = "LOAN_FEE_PAYMENT"
        case loanInterestCharge = "LOAN_INTEREST_CHARGE"
        case sepaCreditTransfer = "SEPA_CREDIT_TRANSFER"
        case sepaDirectDebit = "SEPA_DIRECT_DEBIT"
        case target2CustomerPayment = "TARGET2_CUSTOMER_PAYMENT"
        case fxTransfer = "FX_TRANSFER"
        case issPayment = "ISS_PAYMENT"
        case starlingPayment = "STARLING_PAYMENT"
        case subscriptionCharge = "SUBSCRIPTION_CHARGE"
        case overdraftFee = "OVERDRAFT_FEE"
        case withheldTax = "WITHHELD_TAX"
        case errorsAndOmissions = "ERRORS_AND_OMISSIONS"
        case interestV2Payment = "INTEREST_V2_PAYMENT"
    }
}

extension AccountFeedItem.Source {
    init?(source: GetAccountFeedOutput.FeedItem.Source) {
        self.init(rawValue: source.rawValue)
    }
}

// MARK: - Source Sub Types:
extension GetAccountFeedOutput.FeedItem {
    enum SourceSubType: String, Decodable {
        case contactless = "CONTACTLESS"
        case magneticStrip = "MAGNETIC_STRIP"
        case manualKeyEntry = "MANUAL_KEY_ENTRY"
        case chipAndPin = "CHIP_AND_PIN"
        case online = "ONLINE"
        case atm = "ATM"
        case creditAuth = "CREDIT_AUTH"
        case applePay = "APPLE_PAY"
        case applePayOnline = "APPLE_PAY_ONLINE"
        case androidPay = "ANDROID_PAY"
        case androidPayOnline = "ANDROID_PAY_ONLINE"
        case fitbitPay = "FITBIT_PAY"
        case garminPay = "GARMIN_PAY"
        case samsungPay = "SAMSUNG_PAY"
        case otherWallet = "OTHER_WALLET"
        case cardSubscription = "CARD_SUBSCRIPTION"
        case notApplicable = "NOT_APPLICABLE"
        case unknown = "UNKNOWN"
        case deposit = "DEPOSIT"
        case overdraft = "OVERDRAFT"
        case settleUp = "SETTLE_UP"
        case nearby = "NEARBY"
        case transferSameCurrency = "TRANSFER_SAME_CURRENCY"
        case newCard = "NEW_CARD"
        case newCardOverseas = "NEW_CARD_OVERSEAS"
    }
}
