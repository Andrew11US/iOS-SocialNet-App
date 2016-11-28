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
    @IBOutlet weak var emailTextField: CustomTF!
    @IBOutlet weak var passwordTextField: CustomTF!
    @IBOutlet weak var signInBtn: RoundedButton!
    @IBOutlet weak var logInFacebook: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
    }
    
    @IBAction func logInFacebookPressed(_ sender: AnyObject) {
        
    }

}

