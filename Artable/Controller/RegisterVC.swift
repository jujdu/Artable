//
//  RegisterVC.swift
//  Artable
//
//  Created by Michael Sidoruk on 18/08/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordCheckImage: UIImageView!
    @IBOutlet weak var confirmPasswordCheckImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        confirmPasswordTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        guard let passTxt = passwordTxt.text else { return }
        
        //if we start typing in confirmPassword Textfield
        if textfield == confirmPasswordTxt {
            passwordCheckImage.isHidden = false
            confirmPasswordCheckImage.isHidden = false
        } else {
            if passTxt.isEmpty {
                passwordCheckImage.isHidden = true
                confirmPasswordCheckImage.isHidden = true
                confirmPasswordTxt.text = ""
            }
        }
        
        // make it when the passwords match, the checkmarks turn green color
        if passwordTxt.text == confirmPasswordTxt.text {
            passwordCheckImage.image = UIImage(named: AppImages.GreenCheck)
            confirmPasswordCheckImage.image = UIImage(named: AppImages.GreenCheck)
        } else {
            passwordCheckImage.image = UIImage(named: AppImages.RedCheck)
            confirmPasswordCheckImage.image = UIImage(named: AppImages.RedCheck)
        }
    }
    
    @IBAction func registerClicked(_ sender: Any) {
        
        guard let email = emailTxt.text, email.isNotEmpty,
            let username = usernameTxt.text, username.isNotEmpty,
            let password = passwordTxt.text, password.isNotEmpty else {
                simpleAlert(title: "Error", message: "Please fill out all fileds.")
                return }
        
        guard let confirmPassword = confirmPasswordTxt.text, confirmPassword == password else {
            simpleAlert(title: "Error", message: "Passwords do not match.")
            return
        }
        
//        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
//            if let error = error {
//                self.activityIndicator.stopAnimating()
//                Auth.auth().handleFireAuthError(error: error, vc: self)
//                debugPrint(error)
//                return
//            }
//
//            guard let firUser = result?.user else { return }
//            let artUser = User(id: firUser.uid, email: email, username: username, stripeId: "")
//            //upload to firestore
//            self.createFirestoreUser(user: artUser)
//        }
        
        guard let authUser = Auth.auth().currentUser else { return }

        activityIndicator.startAnimating()

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        authUser.link(with: credential) { (result, error) in
            if let error = error {
                self.activityIndicator.stopAnimating()
                Auth.auth().handleFireAuthError(error: error, vc: self)
                debugPrint(error)
                return
            }
            guard let firUser = result?.user else { return }
            let artUser = User(id: firUser.uid, email: email, username: username, stripeId: "")
            //upload to firestore
            self.createFirestoreUser(user: artUser)
        }
    }
    
    func createFirestoreUser(user: User) {
        //step1: create documt reference
        let newUserRef = Firestore.firestore().collection("users").document(user.id)
        //ste2: create model data
        let data = User.modelToData(user: user)
        //3: upload to firestore
        newUserRef.setData(data) { (error) in
            if let error = error {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                debugPrint("unable to upload new user document")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            self.activityIndicator.stopAnimating()
        }
    }
}
