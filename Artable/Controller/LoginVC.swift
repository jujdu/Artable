
//
//  LoginVC.swift
//  Artable
//
//  Created by Michael Sidoruk on 18/08/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func forgotPasswordClicked(_ sender: Any) {
        let forgotPasswordVC = ForgotPasswordVC(nibName: NibNames.ForgotPasswordVC, bundle: nil)
        //можно было просто инициализировать ForgotPasswordVC()
        forgotPasswordVC.modalTransitionStyle = .crossDissolve
        forgotPasswordVC.modalPresentationStyle = .overFullScreen
        present(forgotPasswordVC, animated: true, completion: nil)
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        guard let email = emailTxt.text, email.isNotEmpty,
            let password = passwordTxt.text, password.isNotEmpty else {
                simpleAlert(title: "Error", message: "Please fill out all fileds.")
                return }
        
        activityIndicator.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            
            guard let strongSelf = self else { return }
            if let error = error {
                debugPrint(error.localizedDescription)
                strongSelf.activityIndicator.stopAnimating()
                Auth.auth().handleFireAuthError(error: error, vc: strongSelf)
                return
            }
            
            strongSelf.activityIndicator.stopAnimating()
            strongSelf.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func guestClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
