//
//  SignUpVC.swift
//  SocialNet
//
//  Created by Andrew Foster on 5/11/17.
//  Copyright © 2017 Andrii Halabuda. All rights reserved.
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

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var password2TextField: CustomTextField!
    @IBOutlet weak var signUpBtn: CustomButton!
    @IBOutlet weak var backBtn: UIButton!
    
    let user = Auth.auth().currentUser
    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.password2TextField.delegate = self
        
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
    }
    
    // Dismiss keyboard function
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Dismiss when return btn pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        password2TextField.resignFirstResponder()
        return true
    }
    
    @IBAction func signUpBtnPressed(_ sender: AnyObject) {
        
        if passwordTextField.text == password2TextField.text {
            print("Identical")
        
        if let email = emailTextField.text, let pwd = passwordTextField.text {
            // Sign In via Firebase using email & password
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
                
                // If error not nil - create new user
                if error != nil {
                    
                    Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        
                        guard let user = user?.user else { return }
                        
                        if error != nil {
                            
                            print("Unable to create account with Firebase")
                            print(error!)
                            
                        } else {
                            
                            print("Successfully created account & authenticated with Firebase")
                            
                            // Creating user
//                            if let user = user {
//                                let username = self.usernameTextField.text
                                let userPicUrl = "gs://socialnet-4d29a.appspot.com/SocialNet.png"

                                // Assign provider
                                let userData = [
                                    "provider": user.providerID,
                                    "username": "none",
                                    "name": "none",
                                    "bio": "bio",
                                    "userPicUrl": userPicUrl
                                ]
                                
                                // Complete sign up & assign UID & userData
                                self.completeSignUp(id: user.uid, userData: userData )
//                            }
                        }
                    })
                    
                } else {
                    // Account already created
                    print("Account already created")
                }
            })
            }
        } else {
            print("Password not match")
            showAlertWithTitle("Error!", message: "Password do not match")
        }
        
        self.view.endEditing(true)
    }
    
    func completeSignUp(id: String, userData: Dictionary<String, String>) {
        // Creating user in Database
        DataService.ds.createFirbaseDBUser(uid: id, userData: userData)
        
        // Using keychain for segue
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: Segues.toSignUp2.rawValue, sender: nil)
    }
    
    func showAlertWithTitle( _ title:String, message:String ) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async { () -> Void in
            
            self.present(alertVC, animated: true, completion: nil)
            
        }
        
    }
    
    /*
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(nameTextField, moveDistance: -20, up: true)
        moveTextField(usernameTextField, moveDistance: -20, up: true)
        moveTextField(emailTextField, moveDistance: -20, up: true)
        moveTextField(passwordTextField, moveDistance: -20, up: true)
        moveTextField(password2TextField, moveDistance: -20, up: true)
        backBtn.isHidden = true
        logo.isHidden = true
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(nameTextField, moveDistance: -20, up: false)
        moveTextField(usernameTextField, moveDistance: -20, up: false)
        moveTextField(emailTextField, moveDistance: -20, up: false)
        moveTextField(passwordTextField, moveDistance: -20, up: false)
        moveTextField(password2TextField, moveDistance: -20, up: false)
        backBtn.isHidden = false
        logo.isHidden = false
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: CustomTextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)

        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
 */

}
