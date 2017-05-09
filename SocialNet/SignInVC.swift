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
import Foundation
import SwiftKeychainWrapper

class SignInVC: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var signInBtn: CustomButton!
    @IBOutlet weak var logInFacebook: CustomButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Facebook login button with public profile permission
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Using keychain if ID is found
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
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
        
        if let email = emailTextField.text, let pwd = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                
                if error == nil {
                    print("Email user authenticated with Firebase")
                    
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                    
                } else {
                    
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        
                        if error != nil {
                            print("Unable to authenticate with Firebase using email")
                            
                        } else {
                            print("Successfully authenticated with Firebase")
                            
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
        
        self.view.endEditing(true)
    }
    
    @IBAction func logInFacebookPressed(_ sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            if error != nil {
                print("Unable to authenticate with Facebook - \(String(describing: error)))")
                
            } else if result?.isCancelled == true {
                
                print("User cancelled Facebook authentication")
                
            } else {
                
                print("Successfully authenticated with Facebook")
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
        self.view.endEditing(true)
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            
            if error != nil {
                
                print("Unable to authenticate with Firebase - \(String(describing: error))")
                
            } else {
                
                print("Successfully authenticated with Firebase")
                
                if let user = user {
                    
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
//        DataService.ds.createFirbaseDBUser(uid: id, userData: userData)
        
        // Using keychain for segue
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }

}

