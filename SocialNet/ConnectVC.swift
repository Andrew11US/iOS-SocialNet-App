//
//  ConnectVC.swift
//  SocialNet
//
//  Created by Agent X on 2/7/18.
//  Copyright © 2018 Andrii Halabuda. All rights reserved.
//

import UIKit
import Firebase

class ConnectVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var users = [User]()
    let userID = Auth.auth().currentUser?.uid
    
    var currentUserMessages = User(userID: (Auth.auth().currentUser?.uid)!, messageKeys: [:])

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
//        getUserData()
        
        // Read data from database
        DataService.ds.REF_USERS.queryOrdered(byChild: "username").observe(.value, with: { (snapshot) in
            
            // Fixes dublicate posts issue
            self.users = []
            
            // Stores temporary data
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
//                    print("USER: \(snap)")
                    if let userDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let user = User(userId: key, userData: userDict)
                        self.users.append(user)
                    }
                }
            }
            self.collectionView.reloadData()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView.reloadData()
        getUserData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MessageVC {
            if let user = sender as? User {
                destination.user = user
            }
        }
    }

}

extension ConnectVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let user = users[indexPath.row]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConnectCell", for: indexPath) as? ConnectCell {
            
            DispatchQueue.main.async {
                cell.configureCell(username: user.name)
            }
            
            return cell
            
        } else {
            
            return ConnectCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        if userID != user.userId {
            if !currentUserMessages.messageKeys.keys.isEmpty {
                
                var exists = false
                
                for (key, value) in currentUserMessages.messageKeys {
                    if key == user.userId {
                        print("Message exists for: ", key)
                        user.assingDialogKey(key: value)
//                        user.assingDialogKey(key: key)
                        exists = true
                    }
                }
                
                if !exists {
                    user.assingDialogKey(key: createDialog(with: user))
                }
                
            } else {
                print("NO dialogs!")
                user.assingDialogKey(key: createDialog(with: user))
            }
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toMessages", sender: user)
            }
            
        } else {
            debugPrint("Message for yourself")
        }

        
        
        
    }
    
    func getUserData() {
        
        let ref = DataService.ds.REF_USER_CURRENT.child("/myMessages")
        ref.observe(.value, with: { (snapshot) in
            
            let value = snapshot.value as? Dictionary<String, String> ?? [:]
            
            self.currentUserMessages = User(userID: self.userID!, messageKeys: value)

            print(self.currentUserMessages.messageKeys.keys)
        })
    }
    
    func createDialog(with: User) -> String {
        
        let key = DataService.ds.REF_MESSAGES.childByAutoId().key!
        
        if userID != with.userId {
            let childUpdates = [
                "/messages/\(key)": "dialog created",
                "/users/\(userID!)/myMessages/\(with.userId)": key,
                "/users/\(with.userId)/myMessages/\(userID!)": key
                
            ]
            DataService.ds.REF_BASE.updateChildValues(childUpdates)
        } else {
            print("Unable to send message for yourself")
        }
        
        return key
    }
    
}
