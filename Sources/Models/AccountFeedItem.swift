import Foundation

public struct AccountFeedItem: Identifiable {
    public let id: UUID
    public let direction: Direction
    public let reference: String?
    public let amount: CurrencyAndAmount?
    public let source: Source?
    public let transactionTime: Date?

    public init(
        id: UUID,
        direction: Direction,
        reference: String?,
        amount: CurrencyAndAmount?,
        source: Source?,
        transactionTime: Date?
    ) {
        self.id = id
        self.direction = direction
        self.reference = reference
        self.amount = amount
        self.source = source
        self.transactionTime = transactionTime
    }
}

extension AccountFeedItem: Equatable, Sendable { }

// MARK: - Direction:
public extension AccountFeedItem {
    enum Direction: Sendable {
        case inbound
        case outbound
    }
}

// MARK: - Source:
public extension AccountFeedItem {
    enum Source: String, Sendable {
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
