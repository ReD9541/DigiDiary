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
    
    private let auth = Auth.auth()
    private let db   = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserProfile()
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    // MARK: - Load User Profile
        private func loadUserProfile() {
            guard let user = auth.currentUser else { return }
            emailLabel.text = user.email
            
            db.collection("users").document(user.uid)
              .getDocument { [weak self] snap, error in
                guard let self = self else { return }
                if let data = snap?.data(), let username = data["username"] as? String {
                    DispatchQueue.main.async { self.usernameTextField.text = username }
                } else if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
        
        // MARK: - Update Username
        @IBAction func resetUsernameTapped(_ sender: UIButton) {
            guard let user = auth.currentUser,
                  let email = user.email,
                  let oldPW = oldpasswordTextField.text, !oldPW.isEmpty,
                  let newName = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newName.isEmpty
            else {
                showAlert(title: "Incomplete Data", message: "Please enter your current password and a new username.")
                return
            }
            
            let credential = EmailAuthProvider.credential(withEmail: email, password: oldPW)
            user.reauthenticate(with: credential) { [weak self] result, error in
                guard let self = self else { return }
                if let error = error {
                    self.showAlert(title: "Authentication Failed", message: error.localizedDescription)
                    return
                }
                // Auth successful; now update username
                self.db.collection("users").document(user.uid)
                  .updateData(["username": newName]) { err in
                    if let err = err {
                        self.showAlert(title: "Update Failed", message: err.localizedDescription)
                    } else {
                        self.showAlert(title: "Success", message: "Username updated.")
                    }
                }
            }
        }
        
        // MARK: - Update Password 
        @IBAction func resetPasswordTapped(_ sender: UIButton) {
            guard let user = auth.currentUser,
                  let email = user.email,
                  let oldPW = oldpasswordTextField.text, !oldPW.isEmpty,
                  let newPW = newPasswordTextField.text, newPW.count >= 6
            else {
                showAlert(title: "Invalid Input", message: "Enter current password and a new password (min 6 chars).")
                return
            }
            
            let credential = EmailAuthProvider.credential(withEmail: email, password: oldPW)
            user.reauthenticate(with: credential) { [weak self] result, error in
                guard let self = self else { return }
                if let error = error {
                    self.showAlert(title: "Authentication Failed", message: error.localizedDescription)
                    return
                }
                // Auth successful; now update password
                user.updatePassword(to: newPW) { err in
                    if let err = err {
                        self.showAlert(title: "Password Reset Failed", message: err.localizedDescription)
                    } else {
                        self.showAlert(title: "Success", message: "Your password has been changed.")
                        DispatchQueue.main.async {
                            self.oldpasswordTextField.text = ""
                            self.newPasswordTextField.text = ""
                        }
                    }
                }
            }
        }
        
        // MARK: - Alerts
        private func showAlert(title: String, message: String) {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(.init(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
