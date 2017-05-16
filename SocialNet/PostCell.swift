//
//  PostCell.swift
//  SocialNet
//
//  Created by Andrew Foster on 5/10/17.
//  Copyright © 2017 Andrii Halabuda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class PostCell: UITableViewCell {
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        doubleTap.numberOfTapsRequired = 2
        
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
        
        postImg.addGestureRecognizer(doubleTap)
        postImg.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, img: UIImage? = nil , pic: UIImage? = nil) {
        
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        self.usernameLbl.text = post.username
        
        // Download Post Image & handle errors
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
                        
                        print("Image downloaded from Firebase storage")
                        if let imgData = data {
                            
                            if let img = UIImage(data: imgData) {
                                
                                self.postImg.image = img
                                // Add downloaded image to cache
                                FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                                
                            }
                        }
                    }
                })
            }
        }
        
        DispatchQueue.main.async {
            if pic != nil {
                
                self.userImg.image = pic
                
            } else {
                
                let ref = FIRStorage.storage().reference(forURL: post.userImageUrl)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    
                    if error != nil {
                        print("Unable to download pic from Firebase storage")
                        print("\(String(describing: error))")
                        self.userImg.image = UIImage(named: "noImage")
                        
                    } else {
                        
                        print("Pic downloaded from Firebase storage")
                        if let imgData = data {
                            
                            if let img = UIImage(data: imgData) {
                                
                                self.userImg.image = img
                                // Add downloaded image to cache
                                FeedVC.imageCache.setObject(img, forKey: post.userImageUrl as NSString)
                                
                            }
                        }
                    }
                })
            }
        }
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "Liked")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
                
            } else {
                self.likeImg.image = UIImage(named: "noLiked")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
}
