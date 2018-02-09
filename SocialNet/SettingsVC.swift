//
//  SettingsVC.swift
//  SocialNet
//
//  Created by Agent X on 2/7/18.
//  Copyright © 2018 Andrii Halabuda. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SwiftKeychainWrapper

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func editBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: Segues.toEditFromSettings.rawValue, sender: nil)
    }
    
    @IBAction func signOutBtnTapped(_ sender: Any) {
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: Segues.toSignIn.rawValue, sender: nil)
        
        self.view.endEditing(true)
    }
    
    
    
}
