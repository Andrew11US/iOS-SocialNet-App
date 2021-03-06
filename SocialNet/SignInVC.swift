//
//  ViewController.swift
//  SocialNet
//
//  Created by Andrew Foster on 11/25/16.
//  Copyright © 2016 Andrii Halabuda. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Foundation
import SwiftKeychainWrapper

class SignInVC: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var signInBtn: CustomButton!
    @IBOutlet weak var logInFacebook: CustomButton!
    @IBOutlet weak var logo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Facebook login button with public profile permission
        /*
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        view.addSubview(loginButton)
        */
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Using keychain if ID is found
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("ID found in keychain")
            performSegue(withIdentifier: Segues.toFeed.rawValue, sender: nil)
        }
        
    }
    
    // Dismiss keyboard function
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Dismiss when return btn pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }

    @IBAction func signInBtnPressed(_ sender: AnyObject) {
        
        // Sign in using E-mail and Password
        if let email = emailTextField.text, let pwd = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
                
                guard let user = user?.user else { return }
                
                if error == nil {
                    print("Email user authenticated with Firebase")
                    
//                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                        
//                    }
                    
                } else {
                    print("Unable to authenticate")
                    
                    self.showAlertWithTitle("Error", message: "E-mail or password is not correct")
                }
            })
        }
        
        self.view.endEditing(true)
    }
    
    @IBAction func logInFacebookPressed(_ sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            if error != nil {
                print("Unable to authenticate with Facebook: \(String(describing: error)))")
                
            } else if result?.isCancelled == true {
                print("User cancelled Facebook authentication")
                
            } else {
                print("Successfully authenticated with Facebook")
                
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
        self.view.endEditing(true)
    }
    
    // Firebase authentication for Facebook logIn using credential
    func firebaseAuth(_ credential: AuthCredential) {
        
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            
            if error != nil {
                
                print("Unable to authenticate with Firebase - \(String(describing: error))")
                
            } else {
                
                print("Successfully authenticated with Firebase")
                
                if let user = user {
                    
                    let userData = [
                        "provider": credential.provider
                    ]
                    self.completeSignUpFacebook(id: user.uid, userData: userData)
                    
                }
            }
        })
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        // Using keychain for segue
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: Segues.toFeed.rawValue, sender: nil)
    }
    
    // If user have no account - it'll be created automatically using FB credentials
    func completeSignUpFacebook(id: String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirbaseDBUser(uid: id, userData: userData)
        
        // Using keychain for segue
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: Segues.toFeed.rawValue, sender: nil)
    }
    
    // Start Editing The Text Field
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        moveTextField(emailTextField, moveDistance: -40, up: true)
//        moveTextField(passwordTextField, moveDistance: -40, up: true)
//    }
    
    // Finish Editing The Text Field
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        moveTextField(emailTextField, moveDistance: -40, up: false)
//        moveTextField(passwordTextField, moveDistance: -40, up: false)
//    }
    
    // Move the text field in a pretty animation!
//    func moveTextField(_ textField: CustomTextField, moveDistance: Int, up: Bool) {
//        let moveDuration = 0.3
//        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
//
//        UIView.beginAnimations("animateTextField", context: nil)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        UIView.setAnimationDuration(moveDuration)
//        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
//        UIView.commitAnimations()
//    }
    
    func showAlertWithTitle( _ title:String, message:String ) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async { () -> Void in
            
            self.present(alertVC, animated: true, completion: nil)
            
        }
        
    }

}

