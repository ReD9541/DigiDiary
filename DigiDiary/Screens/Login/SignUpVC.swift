//
//  SignUpVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseAuth

class SignUpVC: UIViewController {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var SignupButton: UIButton!
    @IBOutlet weak var loginLabelButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StylyzeUI()
        // Do any additional setup after loading the view.
    }
    
    private func StylyzeUI(){
        SignupButton.layer.cornerRadius = 8
        
        loginLabelButton.setTitleColor(.systemBlue, for: .normal)
        loginLabelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let confirm  = confirmPasswordTextField.text ?? ""
        
        
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
        guard password.count >= 6 else {
            return showAlert(title: "Password Too Short", message: "Must be at least 6 characters.")
        }
        guard password == confirm else {
            return showAlert(title: "Passwords Don’t Match", message: "Please make sure both fields match.")
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let err = error {
                self.showAlert(title: "Sign Up Failed", message: err.localizedDescription)
                return
            }
            else{
                self.showAlert(title: "Sign Up Success", message: "You've successfully signed up!")
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
    
    @IBAction func loginLabelTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
}

