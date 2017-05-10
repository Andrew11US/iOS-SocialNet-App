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
    
    @IBOutlet weak var profileImg: UIImageView!
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
        tap.numberOfTapsRequired = 2
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, img: UIImage? = nil ) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        DispatchQueue.main.async {
            if img != nil {
                //            DispatchQueue.main.async {
                //                self.postImg.image = img
                //            }
                self.postImg.image = img
            } else {
                
                let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("Unable to download image from Firebase storage")
                        print("\(String(describing: error))")
                    } else {
                        print("Image downloaded from Firebase storage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                DispatchQueue.main.async {
                                    self.postImg.image = img
                                    FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                                }
                                //                            self.postImg.image = img
                                //                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                            }
                        }
                    }
                })
            }
        }
    }
//        if img != nil {
////            DispatchQueue.main.async {
////                self.postImg.image = img
////            }
//            self.postImg.image = img
//        } else {
//            
//            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
//            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                if error != nil {
//                    print("Unable to download image from Firebase storage")
//                    print("\(String(describing: error))")
//                } else {
//                    print("Image downloaded from Firebase storage")
//                    if let imgData = data {
//                        if let img = UIImage(data: imgData) {
//                            DispatchQueue.main.async {
//                                self.postImg.image = img
//                                FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
//                            }
////                            self.postImg.image = img
////                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
//                        }
//                    }
//                }
//            })
//        }
//        
//        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            if let _ = snapshot.value as? NSNull {
//                self.likeImg.image = UIImage(named: "empty")
//            } else {
//                self.likeImg.image = UIImage(named: "fill")
//            }
//        })
//    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "fill")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
}
