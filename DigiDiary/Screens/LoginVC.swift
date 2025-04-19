//
//  LoginVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
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
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let err = error {
                // Show the error from Firebase (e.g. wrong password, no user)
                self.showAlert(title: "Login Failed", message: err.localizedDescription)
                return
            }
            
            //for successful login
            if let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") {
                    self.navigationController?.pushViewController(homeVC, animated: true)
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
