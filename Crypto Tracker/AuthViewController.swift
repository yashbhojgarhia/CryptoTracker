//
//  AuthViewController.swift
//  Crypto Tracker
//
//  Created by Yash Bhojgarhia on 19/06/21.
//

import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        presentAuth()
    }
    
    func presentAuth() {
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Your crypto is protected by biometrics") { (success, error) in
            if success {
                DispatchQueue.main.async {
                    let navController = UINavigationController(rootViewController: CryptoTableViewController())
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)
                }
            } else {
                self.presentAuth()
            }
        }
    }

}
