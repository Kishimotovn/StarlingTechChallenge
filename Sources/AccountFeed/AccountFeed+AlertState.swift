import Foundation
import ComposableArchitecture
import Models

extension AlertState {
    static var currentSavingsGoalMissingAlert: AlertState<AccountFeed.Action.Alert> {
        .init {
            TextState("Notice!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("Cancel")
            }
            ButtonState(action: .savingsAccountCreationRequired) {
                TextState("Confirm")
            }
        } message: {
            TextState("You don't have a current savings account, do you want to proceed to create one?")
        }
    }

    static func transferToSavingsGoalAlert(request: AccountFeed.State.RoundUpSavingsRequest) -> AlertState<AccountFeed.Action.Alert> {
        .init {
            TextState("Notice!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("Cancel")
            }
            ButtonState(action: .sendRoundUpAmountToSavingsGoal(request: request)) {
                TextState("Confirm")
            }
        } message: {
            TextState("You are about to send this amount \(request.amount.description) to your savings goal.")
        }
    }
    
    static func transferToSavingsGoalSuccessfullyAlert(request: AccountFeed.State.RoundUpSavingsRequest) -> AlertState<AccountFeed.Action.Alert> {
        .init {
            TextState("Notice!")
        } actions: {
            ButtonState(action: .refreshFeed) {
                TextState("Got it!")
            }
        } message: {
            TextState("Successfully sent \(request.amount.description) to your savings goal.")
        }
    }

    static func apiErrorAlert(_ errorMessage: String) -> AlertState<AccountFeed.Action.Alert> {
        .init {
            TextState("Error")
        } actions: {
            ButtonState(action: .apiError(message: errorMessage)) {
                TextState("Ok")
            }
        } message: {
            TextState(errorMessage)
        }
    }
}
