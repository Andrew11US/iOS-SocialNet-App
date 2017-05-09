//
//  ViewController.swift
//  SocialNet
//
//  Created by Andrew Foster on 11/25/16.
//  Copyright © 2016 Andrii Halabuda. All rights reserved.
//

import UIKit

class SignInVC: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var signInBtn: CustomButton!
    @IBOutlet weak var logInFacebook: CustomButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }

    @IBAction func signInBtnPressed(_ sender: AnyObject) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func logInFacebookPressed(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        
    }

}

