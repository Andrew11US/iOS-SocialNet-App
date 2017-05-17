//
//  ProfileVC.swift
//  SocialNet
//
//  Created by Andrew Foster on 5/11/17.
//  Copyright © 2017 Andrii Halabuda. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import Firebase
import SwiftKeychainWrapper

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userPic: CustomImageView!
    
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    var userPicUrl: String!
    var currentUsername: String!
    var posts = [Post]()
//    var usernamesArray = [String]()
    var myPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        updateUI()
        getUserImageUrl()
//        loadMyPosts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        downloadProfilePic()
        loadMyPosts()
        
    }
    
    @IBAction func signOutTapped(_ sender: AnyObject) {
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        
        self.view.endEditing(true)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editProfileBtnTapped(_ sender: Any) {
        
        let superID = [
            "superID": "userDatasuperID"
        ]
        
        let testJSONtree = [
            "test" : "TEST"
        ]
        
        DataService.ds.REF_USER_CURRENT.updateChildValues(superID)
        DataService.ds.REF_USER_CURRENT.child("testTree").updateChildValues(testJSONtree)
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            userPic.image = image
            imageSelected = true
        } else {
            print("Image wasn't selected")
        }
        uploadProfileImg()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func uploadProfileImg() {
        
        guard let img = userPic.image, imageSelected == true else {
            print("An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_USER_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    print("Unable to upload image to Firebasee storage")
                    
                } else {
                    
                    print("Successfully uploaded image to Firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    
                    if let url = downloadURL {
                        self.updateUserPicUrl(imgUrl: url)
                    }
                }
            }
        }
    }
    
    func updateUserPicUrl(imgUrl: String) {
        
        let userPicUrl: Dictionary<String, String> = [
            
            "userPicUrl": imgUrl
        ]
        let firebaseProfileImage = DataService.ds.REF_USER_CURRENT
        firebaseProfileImage.updateChildValues(userPicUrl)
        
        imageSelected = false
    }
    
    func downloadProfilePic(img: UIImage? = nil) {
        
        // Download User Image & handle errors
        DispatchQueue.main.async {
            if img != nil {
                
                self.userPic.image = img
                
            } else {
                
                let ref = FIRStorage.storage().reference(forURL: self.userPicUrl)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    
                    if error != nil {
                        print("Unable to download image from Firebase storage")
                        print("\(String(describing: error))")
                        self.userPic.image = UIImage(named: "noImage")
                        
                    } else {
                        
                        print("Image downloaded from Firebase storage")
                        if let imgData = data {
                            
                            if let img = UIImage(data: imgData) {
                                
                                self.userPic.image = img
                                // Add downloaded image to cache
                                ProfileVC.imageCache.setObject(img, forKey: self.userPicUrl as NSString)
                            }
                        }
                    }
                })
            }
        }
    }
    
    func updateUI() {
        
        let ref = DataService.ds.REF_USER_CURRENT
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
            
            self.usernameLbl.text = username
            self.nameLbl.text = name
            self.currentUsername = username
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getUserImageUrl() {
        
        let ref = DataService.ds.REF_USER_CURRENT
        DispatchQueue.main.async {
            ref.observe(.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let userPic = value?["userPicUrl"] as? String ?? ""
                self.userPicUrl = userPic
                
                print("UPU:" + self.userPicUrl)
            })
        }
    }
    
    func loadMyPosts() {
        let ref = DataService.ds.REF_POSTS
        DispatchQueue.main.async {
            
            ref.observe(.value, with: { (snapshot) in
                
                // Fixes dublicate posts issue
                self.posts = []
                
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        print("SNAPSHOT: \(snap)")
                        let key = snap.key
                        let value = snap.value as? NSDictionary
                        let username = value?["username"] as? String ?? ""
                        
                        print("GETUN:" , username)
                        if self.currentUsername == username {
                            print("EQUAL")
                            let post = Post(postKey: key, postData: value as! Dictionary<String, AnyObject>)
                            self.myPosts.append(post)
                            print("myPOSTS:" , self.myPosts)
                        }
                    }
                    
                }
            })
            
        }
    }
    
}
