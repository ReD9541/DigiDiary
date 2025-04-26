//
//  ProfileSettingsVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class ProfileSettingsVC: UIViewController {
    
    //MARK: INITIALIZATION
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var oldpasswordTextField: UITextField!
    
    private let repository = FirebaseRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        loadUserProfile()
    }
    
    
    // MARK: - Load User Profile
    // MARK: - Load Profile
    private func loadUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        emailLabel.text = user.email
        repository.fetchUsername(for: user.uid) { [weak self] username, error in
            DispatchQueue.main.async {
                if let name = username {
                    self?.usernameTextField.text = name
                } else {
                    self?.showAlert(title: "Error", message: error?.localizedDescription ?? "Unable to load username.")
                }
            }
        }
    }
    
    // MARK: - Update Username
    @IBAction func resetUsernameTapped(_ sender: UIButton) {
        guard let currentPW = oldpasswordTextField.text, !currentPW.isEmpty,
              let newName = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !newName.isEmpty else {
            showAlert(title: "Incomplete Data",
                      message: "Please enter your current password and a new username.")
            return
        }
        
        repository.updateUsername(currentPassword: currentPW,
                                  newUsername: newName) { [weak self] error in
            DispatchQueue.main.async {
                if let err = error {
                    self?.showAlert(title: "Update Failed", message: err.localizedDescription)
                } else {
                    self?.showAlert(title: "Success", message: "Username updated.")
                    self?.oldpasswordTextField.text = ""
                }
            }
        }
    }
    
    // MARK: - Update Password
    @IBAction func resetPasswordTapped(_ sender: UIButton) {
        guard let currentPW = oldpasswordTextField.text, !currentPW.isEmpty,
              let newPW = newPasswordTextField.text, newPW.count >= 6 else {
            showAlert(title: "Invalid Input",
                      message: "Enter current password and a new password (min 6 chars).")
            return
        }
        
        repository.updatePassword(currentPassword: currentPW,
                                  newPassword: newPW) { [weak self] error in
            DispatchQueue.main.async {
                if let err = error {
                    self?.showAlert(title: "Password Reset Failed", message: err.localizedDescription)
                } else {
                    self?.showAlert(title: "Success", message: "Your password has been changed.")
                    self?.oldpasswordTextField.text = ""
                    self?.newPasswordTextField.text = ""
                }
            }
        }
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "unwindToLoginSegue", sender: self)
        } catch {
            showAlert(title: "Logout Failed", message: error.localizedDescription)
        }
    }
    
    
}
