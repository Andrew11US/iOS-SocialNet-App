//
//  Post.swift
//  SocialNet
//
//  Created by Andrew Foster on 5/10/17.
//  Copyright © 2017 Andrii Halabuda. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class Post {
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _username: String!
    private var _name: String!
    private var _userPicUrl: String!
    private var _postKey: String!
    private var _postRef: DatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var name: String {
        return _name
    }
    
    var userPicUrl: String {
        return _userPicUrl
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(caption: String, imageUrl: String, likes: Int, username: String, userPicUrl: String, name: String) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        self._username = username
        self._userPicUrl = userPicUrl
        self._name = name
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let username = postData["username"] as? String {
            self._username = username
        }
        
        if let userPicUrl = postData["userPicUrl"] as? String {
            self._userPicUrl = userPicUrl
        }
        
        if let name = postData["name"] as? String {
            self._name = name
        }
        
        _postRef = DataService.ds.REF_POSTS.child(postKey)
        
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = likes - 1
        }
        _postRef.child("likes").setValue(_likes)
        
    }
    
}
