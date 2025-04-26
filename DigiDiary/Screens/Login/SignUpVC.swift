//
//  SignUpVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpVC: UIViewController {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var SignupButton: UIButton!
    @IBOutlet private weak var loginLabelButton: UIButton!
    @IBOutlet private weak var usernameTextField: UITextField!
    
    // MARK: - Properties
    
    private let repository = FirebaseRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StylyzeUI()
    }
    
    private func StylyzeUI(){
        SignupButton.layer.cornerRadius = 8
        
        loginLabelButton.setTitleColor(.systemBlue, for: .normal)
        loginLabelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let email    = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let confirm  = confirmPasswordTextField.text ?? ""
        let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // validate
        guard !email.isEmpty else {
            return showAlert(title: "Email Required", message: "Please enter your email.")
        }
        guard isValidEmail(email) else {
            return showAlert(title: "Invalid Email", message: "Please enter a valid email.")
        }
        guard !password.isEmpty else {
            return showAlert(title: "Password Required", message: "Please enter a password.")
        }
        guard password.count >= 6 else {
            return showAlert(title: "Password Too Short", message: "Must be at least 6 characters.")
        }
        guard password == confirm else {
            return showAlert(title: "Passwords Don’t Match", message: "Please make sure both fields match.")
        }
        guard !username.isEmpty else {
            return showAlert(title: "Username Required", message: "Please enter a username.")
        }
        
        repository.createUser(email: email,
                              password: password,
                              username: username) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(title: "Sign Up Failed",
                                    message: error.localizedDescription)
                } else {
                    self?.showAlert(title: "Success",
                                    message: "Account created! You can now log in.") { _ in
                        self?.performSegue(withIdentifier: "unwindToLogin", sender: nil)
                    }
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    
    @IBAction func loginLabelTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToLogin", sender: nil)
    }
}

