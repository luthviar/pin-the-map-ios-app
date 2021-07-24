//
//  LoginViewController.swift
//  Pin the Map
//
//  Created by Luthfi Abdurrahim on 21/07/21.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets and Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let signUpUrl = AppClient.Endpoints.udacitySignUp.url
    
    var emailTextFieldIsEmpty = true
    var passwordTextFieldIsEmpty = true
    
    enum LoginViewButtonTags: Int {
        case loginButton = 1
        case signUpButton = 2
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = ""
        passwordTextField.text = ""
        emailTextField.delegate = self
        passwordTextField.delegate = self
        buttonEnabled(false, button: loginButton)
        loginButton.tag = LoginViewButtonTags.loginButton.rawValue
        signUpButton.tag = LoginViewButtonTags.signUpButton.rawValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    // MARK: IBAction
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        setLoggingIn(true)
        switch LoginViewButtonTags(rawValue: sender.tag) {
        case .loginButton:
            AppClient.login(email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
        case .signUpButton:
            UIApplication.shared.open(signUpUrl, options: [:], completionHandler: nil)
        case .none:
            print("button undefined")
        }
    }
    
    // MARK: Handle login response
    
    func handleLoginResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        success == true ? self.presentTabBarView(from: self) : showAlert(message: error?.localizedDescription ?? "Error, please try again.", title: "Login Failed")        
    }
    
    // MARK: Loading state
    
    func setLoggingIn(_ loggingIn: Bool) {
        DispatchQueue.main.async {
            loggingIn ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            self.buttonEnabled(!loggingIn, button: self.loginButton)
            self.emailTextField.isEnabled = !loggingIn
            self.passwordTextField.isEnabled = !loggingIn
            self.loginButton.isEnabled = !loggingIn
            self.signUpButton.isEnabled = !loggingIn
        }        
    }
    
    // MARK: Text Fields Delegate Protocol
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            let currenText = emailTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if !isValidEmail(email: updatedText) {
                emailTextFieldIsEmpty = true
            } else {
                emailTextFieldIsEmpty = false
            }
        }
        
        if textField == passwordTextField {
            let currenText = passwordTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                passwordTextFieldIsEmpty = true
            } else {
                passwordTextFieldIsEmpty = false
            }
        }
        
        if !emailTextFieldIsEmpty && !passwordTextFieldIsEmpty {
            buttonEnabled(true, button: loginButton)
        } else {
            buttonEnabled(false, button: loginButton)
        }
        
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        buttonEnabled(false, button: loginButton)
        if textField == emailTextField {
            emailTextFieldIsEmpty = true
        }
        if textField == passwordTextField {
            passwordTextFieldIsEmpty = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if !emailTextFieldIsEmpty && !passwordTextFieldIsEmpty {
                buttonPressed(loginButton)
            }
        }
        return true
    }
    
}


