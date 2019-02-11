//
//  MessageVC.swift
//  SocialNet
//
//  Created by Agent X on 2/7/18.
//  Copyright © 2018 Andrii Halabuda. All rights reserved.
//

import UIKit
import Firebase

class MessageVC: UIViewController {

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            
            // Fixes dublicate posts issue
            self.users = []
            
            // Stores temporary data
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("USER: \(snap.key)")
                    if let userDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let user = User(userId: key, userData: userDict)
                        self.users.append(user)
//                        print(self.users[0].userId)
                    }
                }
            }
//            self.collectionView.reloadData()
        })
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show()
    }

    func show() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            for user in self.users {
                print(user.name)
            }
        }
//        DispatchQueue.main.async {
//            for user in self.users {
//                print(user.name)
//            }
//        }
        
    }


}
