//
//  SignUp2VC.swift
//  SocialNet
//
//  Created by Agent X on 2/8/18.
//  Copyright © 2018 Andrii Halabuda. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import Firebase

class SignUp2VC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var nameTextField: CustomTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.delegate = self
        self.nameTextField.delegate = self
        
        getUserData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Dismiss when return btn pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        
        guard let username = usernameTextField.text, username != "" else {
            print("Username must be entered")
            return
        }
        
        guard let name = nameTextField.text, name != "" else {
            print("Username must be entered")
            return
        }
        
        let childUpdates = [
            
            "/username": usernameTextField.text! as AnyObject,
            "/name": nameTextField.text! as AnyObject
        ]
        
        DataService.ds.REF_USER_CURRENT.updateChildValues(childUpdates)
        
        performSegue(withIdentifier: Segues.toSignUp3.rawValue, sender: nil)
        self.view.endEditing(true)
    }
    
    func getUserData() {
        
        let ref = DataService.ds.REF_USER_CURRENT
        DispatchQueue.main.async {
            ref.observe(.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let userPic = value?["userPicUrl"] as? String ?? ""
                let username = value?["username"] as? String ?? ""
                
                print("UPU:" + userPic)
                print("UN:" + username)
            })
        }
    }


}
