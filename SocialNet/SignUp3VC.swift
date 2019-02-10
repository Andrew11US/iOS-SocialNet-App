//
//  SignUp3VC.swift
//  SocialNet
//
//  Created by Agent X on 2/8/18.
//  Copyright © 2018 Andrii Halabuda. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import Firebase
import SwiftKeychainWrapper

class SignUp3VC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userPic: CustomImageView!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: Segues.toFeedFromSignUp.rawValue, sender: nil)
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
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_USER_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    print("Unable to upload image to Firebasee storage")
                    
                } else {
                    
                    print("Successfully uploaded image to Firebase storage")
                    
                    DataService.ds.REF_USER_IMAGES.child(imgUid).downloadURL(completion: { (url, error) in
                        if let err = error {
                            debugPrint(err.localizedDescription)
                        } else {
                            let downloadURL = url?.absoluteString
                            
                            if let url = downloadURL {
                                self.updateUserPicUrl(imgUrl: url)
                            }
                        }
                    })
                    
//                    let downloadURL = metadata?.downloadURL()?.absoluteString
//                    
//                    if let url = downloadURL {
//                        self.updateUserPicUrl(imgUrl: url)
//                    }
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

}
