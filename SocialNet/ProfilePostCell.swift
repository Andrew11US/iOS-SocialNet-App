//
//  ProfilePostCell.swift
//  SocialNet
//
//  Created by Andrew Foster on 5/17/17.
//  Copyright © 2017 Andrii Halabuda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfilePostCell: UITableViewCell {

    @IBOutlet weak var postImg: UIImageView!
    var post: Post!
    
    func configureCell(post: Post, img: UIImage? = nil) {
        
        self.post = post
        
        DispatchQueue.main.async {
            if img != nil {
                
                self.postImg.image = img
                
            } else {
                
                let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    
                    if error != nil {
                        print("Unable to download image from Firebase storage")
                        print("\(String(describing: error))")
                        self.postImg.image = UIImage(named: "noImage")
                        
                    } else {
                        
                        print("Image Downloaded")
                        if let imgData = data {
                            
                            if let img = UIImage(data: imgData) {
                                
                                self.postImg.image = img
                                // Add downloaded image to cache
                                ProfileVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                                
                            }
                        }
                    }
                })
            }
        }
    }
}
