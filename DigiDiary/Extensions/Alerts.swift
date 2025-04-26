//
//  Alerts.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 26/4/2025.
//

import UIKit

extension UIViewController {
    /// Present a simple alert with an OK button.
    func showAlert(title: String,
                   message: String,
                   actionTitle: String = "OK",
                   handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: actionTitle,
                style: .default,
                handler: handler
            )
        )
        present(alert, animated: true)
    }
}
