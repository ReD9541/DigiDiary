//
//  LoginVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    // MARK: - Initialization

    @IBOutlet private weak var signupLabelButton: UIButton!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stylizeUI()
        
        // Do any additional setup after loading the view.
    }
    
    private func stylizeUI() {
        loginButton.layer.cornerRadius = 8
        
        signupLabelButton.setTitleColor(.systemBlue, for: .normal)
        signupLabelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
    }
    

    @IBAction func loginTapped(_ sender: UIButton) {
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        //to validate that the users are providing the correct type of values
        guard !email.isEmpty else {
            return showAlert(title: "Email Required", message: "Please enter your email.")
        }
        guard isValidEmail(email) else {
            return showAlert(title: "Invalid Email", message: "Please enter a valid email.")
        }
        guard !password.isEmpty else {
            return showAlert(title: "Password Required", message: "Please enter a password.")
        }
        
        // MARK: - Authentication and Navigation
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let err = error {
                // Show the error from Firebase (e.g. wrong password, no user)
                self.showAlert(title: "Login Failed", message: err.localizedDescription)
                return
            }
            
            //for successful login
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as? UITabBarController {
                tabBarVC.modalPresentationStyle = .fullScreen
                
                tabBarVC.selectedIndex = 2
                self.present(tabBarVC, animated: true, completion: nil)
            }
        }
    }
    
    
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(.init(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}
