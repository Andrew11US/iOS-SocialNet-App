//
//  PostVC.swift
//  SocialNet
//
//  Created by Andrew Foster on 5/11/17.
//  Copyright © 2017 Andrii Halabuda. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import Firebase

class PostVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var captionField: CustomTextField!
    @IBOutlet weak var imageAdd: UIImageView!
    @IBOutlet weak var userPic: CustomImageView!
    
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    let userID = FIRAuth.auth()?.currentUser?.uid
    var username: String!
    var name: String!
    var userPicUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.captionField.delegate = self
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        print(userID!)
        getUserData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        downloadProfilePic()
    }
    
    // Dismiss keyboard function
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Dismiss when return btn pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        captionField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: AnyObject) {
        
        guard let caption = captionField.text, caption != "" else {
            print("Caption must be entered")
            return
        }
        
        guard let img = imageAdd.image, imageSelected == true else {
            print("An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("Unable to upload image to Firebasee storage")
                } else {
                    print("Successfully uploaded image to Firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
    }
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, AnyObject> = [
            
            "caption": captionField.text! as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject,
            "userID": userID as AnyObject,
            "username": username as AnyObject,
            "userPicUrl": userPicUrl as AnyObject,
            "timeStamp": FIRServerValue.timestamp() as AnyObject,
            "name": name as AnyObject
        ]
        
        let key = DataService.ds.REF_POSTS.childByAutoId().key
//        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
//        firebasePost.setValue(post)
        
        let childUpdates = [
            
            "/posts/\(key)": post,
            "/users/\(userID!)/myPosts/\(key)/": post
        ]
        DataService.ds.REF_BASE.updateChildValues(childUpdates)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "noImage")
        
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
    }
    
    func getUserData() {
        
        let ref = DataService.ds.REF_USER_CURRENT
        DispatchQueue.main.async {
            ref.observe(.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let userPic = value?["userPicUrl"] as? String ?? ""
                let username = value?["username"] as? String ?? ""
                let name = value?["name"] as? String ?? ""
                self.userPicUrl = userPic
                self.username = username
                self.name = name
                
                print("UPU:" + self.userPicUrl)
                print("UN:" + self.username)
                print("N" + self.name)
            })
        }
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
                                PostVC.imageCache.setObject(img, forKey: self.userPicUrl as NSString)
                            }
                        }
                    }
                })
            }
        }
    }

}
