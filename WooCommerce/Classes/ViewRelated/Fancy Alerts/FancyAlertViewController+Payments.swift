import Foundation
import WordPressUI

/// We are going to need to write a new modal view to present user facing messages related to payments.
/// https://github.com/woocommerce/woocommerce-ios/issues/3980
/// In the meantime, this, based on FancyAlertViewController, will have to do.
/// This extension will probably be removed when 3980 is implemented
public extension FancyAlertViewController {

    static func makeCollectPaymentAlert(name: String, amount: String, image: UIImage) -> FancyAlertViewController {

        let config = configuration(title: name, bodyText: amount, image: image)

        let controller = FancyAlertViewController.controllerWithConfiguration(configuration: config)
        return controller
    }

    static func configuration(title: String, bodyText: String, image: UIImage) -> FancyAlertViewController.Config {
        FancyAlertViewController.Config(titleText: title,
                                        bodyText: bodyText,
                                        headerImage: image,
                                        dividerPosition: .top,
                                        defaultButton: nil,
                                        cancelButton: nil,
                                        moreInfoButton: nil,
                                        dismissAction: {})
    }

    static func configurationForSuccess(title: String, bodyText: String, image: UIImage,
                                        printAction: @escaping () -> Void,
                                        emailAction: @escaping () -> Void) -> FancyAlertViewController.Config {
        FancyAlertViewController.Config(titleText: title,
                                        bodyText: bodyText,
                                        headerImage: image,
                                        dividerPosition: .top,
                                        defaultButton: makePrintButon(printAction: printAction),
                                        cancelButton: makeEmailButton(emailAction: emailAction),
                                        moreInfoButton: makeNoThanksButton(),
                                        dismissAction: {})
    }

    static func configurationForError(image: UIImage,
                                        tryAgainAction: @escaping () -> Void) -> FancyAlertViewController.Config {
        FancyAlertViewController.Config(titleText: Localization.tryAgain,
                                        bodyText: nil,
                                        headerImage: image,
                                        dividerPosition: .top,
                                        defaultButton: makeTryAgain(tryAgainAction: tryAgainAction),
                                        cancelButton: nil,
                                        moreInfoButton: nil,
                                        dismissAction: {})
    }

    private static func makePrintButon(printAction: @escaping () -> Void) -> FancyAlertViewController.Config.ButtonConfig {
        return FancyAlertViewController.Config.ButtonConfig(Localization.printReceipt) { controller, _ in
            printAction()
            controller.dismiss(animated: true)
        }
    }

    private static func makeEmailButton(emailAction: @escaping () -> Void) -> FancyAlertViewController.Config.ButtonConfig {
        return FancyAlertViewController.Config.ButtonConfig(Localization.emailReceipt) { controller, _ in
            emailAction()
            controller.dismiss(animated: true)
        }
    }

    private static func makeNoThanksButton() -> FancyAlertViewController.Config.ButtonConfig {
        return FancyAlertViewController.Config.ButtonConfig(Localization.noThanks) { controller, _ in
            controller.dismiss(animated: true)
        }
    }

    private static func makeTryAgain(tryAgainAction: @escaping () -> Void) -> FancyAlertViewController.Config.ButtonConfig {
        return FancyAlertViewController.Config.ButtonConfig(Localization.tryAgain) { controller, _ in
            tryAgainAction()
            controller.dismiss(animated: true)
        }
    }
}


private extension FancyAlertViewController {
    enum Localization {
        static let printReceipt = NSLocalizedString(
            "Print receipt",
            comment: "Button to print receipts. Presented to users after a payment has been successfully collected"
        )

        static let emailReceipt = NSLocalizedString(
            "Email receipt",
            comment: "Button to email receipts. Presented to users after a payment has been successfully collected"
        )

        static let noThanks = NSLocalizedString(
            "No thanks",
            comment: "Button to dismiss modal overlay. Presented to users after a payment has been successfully collected"
        )

        static let paymentFailed = NSLocalizedString(
            "Payment failed",
            comment: "Error message. Presented to users after a collecting a payment fails"
        )

        static let tryAgain = NSLocalizedString(
            "Try collecting payment again",
            comment: "Button to try to collect a payment again. Presented to users after a collecting a payment fails"
        )
    }
}
