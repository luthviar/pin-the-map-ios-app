//
//  Extensions.swift
//  Pin the Map
//
//  Created by Luthfi Abdurrahim on 23/07/21.
//

import UIKit

extension UIViewController {
    
    func buttonEnabled(_ enabled: Bool, button: UIButton) {
        button.isEnabled = enabled
        button.alpha = enabled ? 1.0 : 0.5        
    }
    
    func showAlert(message: String, title: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
    
    func openLink(_ url: String) {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
            showAlert(message: "Cannot open link.", title: "Invalid Link")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
    
    func isValidEmail(email: String) -> Bool {
        // Code from: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func presentTabBarView(from: UIViewController) {
        let tabBarView = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        tabBarView.modalPresentationStyle = .fullScreen
        from.present(tabBarView, animated: true, completion: nil)
    }
    
    func presentAddPinDataView(from: UIViewController) {        
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "navigationToAddPinDataVC") as! UINavigationController
        navigationController.modalPresentationStyle = .fullScreen
        from.present(navigationController, animated: true, completion: nil)
    }

    func isValidURL(text: String) -> Bool {
        guard let url = URL(string: text), UIApplication.shared.canOpenURL(url) else {
           return false
        }
        return true
    }
}
