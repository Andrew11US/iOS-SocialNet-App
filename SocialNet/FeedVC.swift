//
//  FeedVC.swift
//  SocialNet
//
//  Created by Andrew Foster on 5/9/17.
//  Copyright © 2017 Andrii Halabuda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileBtn: UIButton!
    
    var posts = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getUserData()
        
        // Read data from database
        DataService.ds.REF_POSTS.queryOrdered(byChild: "timeStamp").observe(.value, with: { (snapshot) in
            
            // Fixes dublicate posts issue
            self.posts = []
            
            // Stores temporary data 
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Dismiss when return btn pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            DispatchQueue.main.async {
                if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) , let pic = FeedVC.imageCache.object(forKey: post.userPicUrl as NSString) {
                    
                    cell.configureCell(post: post, img: img, pic: pic)
                } else {
                    
                    cell.configureCell(post: post)
                }
            }
            
            return cell
            
        } else {
            
            return PostCell()
        }
    }
    
    func getUserData() {
        
        let ref = DataService.ds.REF_USER_CURRENT
        ref.observe(.value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let userPic = value?["userPicUrl"] as? String ?? ""
            let username = value?["username"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
            
            if username == "" && userPic == "" && name == "" {
                setToDefault()
            }
            
            print("UPU:" + userPic)
            print("UN:" + username)
            print("NAME:" + name)
        })
        
        func setToDefault() {
            
            let userID = FIRAuth.auth()?.currentUser?.uid
            
            let childUpdates = [
                
                "/username": userID as AnyObject,
                "/name": "none" as AnyObject,
                "/bio": "bio" as AnyObject,
                "/userPicUrl": "gs://socialnet-4d29a.appspot.com/SocialNet.png" as AnyObject
                ]
            
            DataService.ds.REF_USER_CURRENT.updateChildValues(childUpdates)
        }
    }
    
}
