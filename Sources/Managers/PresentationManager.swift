//
//  PresentationManager.swift
//  Siren
//
//  Created by Arthur Sabintsev on 12/6/17.
//  Copyright © 2017 Sabintsev iOS Projects. All rights reserved.
//

import UIKit

/// PresentationManager for Siren
public struct PresentationManager {
    /// Return results or errors obtained from performing a version check with Siren.
    typealias CompletionHandler = (AlertAction) -> Void

    /// The localization data structure that will be used to construct localized strings for the update alert.
    let localization: Localization

    /// The tint color of the `UIAlertController` buttons.
    let tintColor: UIColor?

    /// The descriptive update message of the `UIAlertController`.
    let alertMessage: String

    /// The main message of the `UIAlertController`.
    let alertTitle: String

    /// The "Next time" button text of the `UIAlertController`.
    let nextTimeButtonTitle: String

    /// The "Skip this version" button text of the `UIAlertController`.
    let skipButtonTitle: String

    /// The "Update" button text of the `UIAlertController`.
    let updateButtonTitle: String

    /// The instance of the `UIAlertController` used to present the update alert.
    var alertController: UIAlertController?

    /// The `UIWindow` instance that presents the `SirenViewController`.
    private var updaterWindow: UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = UIWindow.Level.alert + 1

        let viewController = SirenViewController()
        viewController.retainedWindow = window

        window.rootViewController = viewController
        return window
    }

    /// `PresentationManager`'s public initializer.
    ///
    /// - Parameters:
    ///     - tintColor: The alert's tintColor. Settings this to `nil` defaults to the system default color.
    ///     - appName: The name of the app (overrides the default/bundled name).
    ///     - alertTitle: The title field of the `UIAlertController`.
    ///     - alertMessage: The `message` field of the `UIAlertController`.
    ///     - nextTimeButtonTitle: The `title` field of the Next Time Button `UIAlertAction`.
    ///     - skipButtonTitle: The `title` field of the Skip Button `UIAlertAction`.
    ///     - updateButtonTitle: The `title` field of the Update Button `UIAlertAction`.
    ///     - forceLanguage: The language the alert to which the alert should be set. If `nil`, it falls back to the device's preferred locale.
    public init(alertTintColor tintColor: UIColor? = nil,
                appName: String? = nil,
                alertTitle: String  = AlertConstants.alertTitle,
                alertMessage: String  = AlertConstants.alertMessage,
                updateButtonTitle: String  = AlertConstants.updateButtonTitle,
                nextTimeButtonTitle: String  = AlertConstants.nextTimeButtonTitle,
                skipButtonTitle: String  = AlertConstants.skipButtonTitle,
                forceLanguageLocalization forceLanguage: Localization.Language? = nil) {
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.localization = Localization(appName: appName, andForceLanguageLocalization: forceLanguage)
        self.nextTimeButtonTitle = nextTimeButtonTitle
        self.updateButtonTitle = updateButtonTitle
        self.skipButtonTitle = skipButtonTitle
        self.tintColor = tintColor
    }

    /// The default `PresentationManager`.
    ///
    /// By default:
    /// - There is no tint color (defaults to Apple's system `blue` color.)
    /// - The name of the app is equal to the name that appears in `Info.plist`.
    /// - The strings are all set to that of the user's device localization (if supported) or it falls back to English.
    public static let `default` = PresentationManager()
}

// MARK: - Alert Lifecycle

extension PresentationManager {

    /// Constructs the localized update alert `UIAlertController` object.
    ///
    /// - Parameters:
    ///   - rules: The rules that are used to define the type of alert that should be presented.
    ///   - currentAppStoreVersion: The current version of the app in the App Store.
    ///   - handler: The completion handler that returns the an `AlertAction` depending on the type of action the end-user took.
    mutating func presentAlert(withRules rules: Rules,
                               forCurrentAppStoreVersion currentAppStoreVersion: String,
                               completion handler: CompletionHandler?) {
        UserDefaults.alertPresentationDate = Date()

        // Alert Title
        let alertTitle: String
        if self.alertTitle == AlertConstants.alertTitle {
            alertTitle = localization.alertTitle()
        } else {
            alertTitle = self.alertTitle
        }

        // Alert Message
        let alertMessage: String
        if self.alertMessage == AlertConstants.alertMessage {
            alertMessage = localization.alertMessage(forCurrentAppStoreVersion: currentAppStoreVersion)
        } else {
            alertMessage = self.alertMessage
        }

        alertController = UIAlertController(title: alertTitle,
                                            message: alertMessage,
                                            preferredStyle: .alert)

        if let tintColor = tintColor {
            alertController?.view.tintColor = tintColor
        }

        switch rules.alertType {
        case .force:
            alertController?.addAction(updateAlertAction(completion: handler))
        case .option:
            alertController?.addAction(nextTimeAlertAction(completion: handler))
            alertController?.addAction(updateAlertAction(completion: handler))
        case .skip:
            alertController?.addAction(updateAlertAction(completion: handler))
            alertController?.addAction(nextTimeAlertAction(completion: handler))
            alertController?.addAction(skipAlertAction(forCurrentAppStoreVersion: currentAppStoreVersion, completion: handler))
        case .none:
            handler?(.unknown)
        }

        // If the alertType is .none, an alert will not be presented.
        // If the `updaterWindow` is not hidden, then an alert is already presented.
        // The latter prevents `UIAlertControllers` from appearing on top of each other.
        if rules.alertType != .none, updaterWindow.isHidden {
            alertController?.show(window: updaterWindow)
        }
    }

    /// Removes the `alertController` from memory.
    func cleanUp() {
        alertController?.hide(window: updaterWindow)
        alertController?.dismiss(animated: true, completion: nil)
        self.updaterWindow.rootViewController = nil
        self.updaterWindow.resignKey()
        self.updaterWindow.removeFromSuperview()
    }
}

// MARK: - Alert Actions

private extension PresentationManager {

    /// The `UIAlertAction` that is executed when the `Update` option is selected.
    ///
    /// - Parameters:
    ///   - handler: The completion handler that returns the `.update` option.
    /// - Returns: The `Update` alert action.
    func updateAlertAction(completion handler: CompletionHandler?) -> UIAlertAction {
        let title: String
        if self.updateButtonTitle == AlertConstants.updateButtonTitle {
            title = localization.updateButtonTitle()
        } else {
            title = self.updateButtonTitle
        }

        let action = UIAlertAction(title: title, style: .default) { _ in
            self.cleanUp()
            Siren.shared.launchAppStore()

            handler?(.appStore)
            return
        }

        return action
    }

    /// The `UIAlertAction` that is executed when the `Next time` option is selected.
    ///
    /// - Parameters:
    ///   - handler: The completion handler that returns the `.nextTime` option.
    /// - Returns: The `Next time` alert action.
    func nextTimeAlertAction(completion handler: CompletionHandler?) -> UIAlertAction {
        let title: String
        if self.nextTimeButtonTitle == AlertConstants.nextTimeButtonTitle {
            title = localization.nextTimeButtonTitle()
        } else {
            title = self.nextTimeButtonTitle
        }

        let action = UIAlertAction(title: title, style: .default) { _ in
            self.cleanUp()

            handler?(.nextTime)
            return
        }

        return action
    }

    /// The `UIAlertAction` that is executed when the `Skip this version` option is selected.
    ///
    /// - Parameters:
    ///   - currentAppStoreVersion: The current version of the app in the App Store.
    ///   - handler: The completion handler that returns the `.skip` option.
    /// - Returns: The `Skip this version` alert action.
    func skipAlertAction(forCurrentAppStoreVersion currentAppStoreVersion: String, completion handler: CompletionHandler?) -> UIAlertAction {
        let title: String
        if self.skipButtonTitle == AlertConstants.skipButtonTitle {
            title = localization.skipButtonTitle()
        } else {
            title = self.skipButtonTitle
        }

        let action = UIAlertAction(title: title, style: .default) { _ in
            UserDefaults.storedSkippedVersion = currentAppStoreVersion
            UserDefaults.standard.synchronize()

            self.cleanUp()

            handler?(.skip)
            return
        }

        return action
    }
}
