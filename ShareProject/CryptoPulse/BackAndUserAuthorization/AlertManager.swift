//
//  AlertManager.swift
//  userLoginWithNode
//
//  Created by Vitaly on 11.10.2023.
//

import Foundation
import UIKit

class AlertManager {
    
    private static func showBasicAlert(on vc: UIViewController, with title: String, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            vc.present(alert, animated: true)
        }
    }
}

// MARK: - Show Validation Alerts
extension AlertManager {
    public static func showInvalidEmailAlert(on vc: UIViewController) {
        showBasicAlert(on: vc, with: "Invalid Email", message: "Please enter a valid email.")
    }
    
    public static func showInvalidPasswordAlert(on vc: UIViewController) {
        showBasicAlert(on: vc, with: "Invalid Password", message: "Please enter a valid password.")
    }
    
    public static func showInvalidUsernameAlert(on vc: UIViewController) {
        showBasicAlert(on: vc, with: "Invalid Username", message: "Please enter a valid username.")
    }
}


// MARK: - Registration Errors
extension AlertManager {
    public static func showRegistrationErrorAlert(on vc: UIViewController) {
        showBasicAlert(on: vc, with: "Unknown Registration Error", message: nil)
    }
    
    public static func showRegistrationErrorAlert(on vc: UIViewController, with error: String) {
        showBasicAlert(on: vc, with: "Unknown Registration Error", message: "\(error)")
    }
}


// MARK: - Log In Errors
extension AlertManager {
    public static func showSignInErrorAlert(on vc: UIViewController) {
        showBasicAlert(on: vc, with: "Unknown Error Sighing In", message: nil)
    }
    
    public static func showSignInErrorAlert(on vc: UIViewController, with error: String) {
        showBasicAlert(on: vc, with: "Error Sighing In", message: "\(error)")
    }
}

// MARK: - Log Out Errors
extension AlertManager {
    public static func showLogOutErrorAlert(on vc: UIViewController, with error: Error) {
        showBasicAlert(on: vc, with: "Log Out Error", message: "\(error.localizedDescription)")
    }
}

// MARK: - Forgot Password
extension AlertManager {
    
    public static func showPasswordResetSentAlert(on vc: UIViewController) {
        showBasicAlert(on: vc, with: "Password Reset Sent", message: nil)
    }
    
    public static func showErrorSendingPasswordResetAlert(on vc: UIViewController, with error: String) {
        showBasicAlert(on: vc, with: "Error Sending Password Reset", message: "\(error)")
    }
}

// MARK: - Fetching User Errors
extension AlertManager {
    
    public static func showUnknownFetchingUserErrorAlert(on vc: UIViewController) {
        showBasicAlert(on: vc, with: "Unknown Error Fetching User", message: nil)
    }
    
    public static func showFetchingUserErrorAlert(on vc: UIViewController, with error: Error) {
        showBasicAlert(on: vc, with: "Error Fetching User", message: "\(error.localizedDescription)")
    }
}
