//
//  DataService.swift
//  SocialNet
//
//  Created by Andrew Foster on 5/10/17.
//  Copyright © 2017 Andrii Halabuda. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import SwiftKeychainWrapper

// Database & storage references
let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    // DB references
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_MESSAGES = DB_BASE.child("messages")
    
    // Storage references
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    private var _REF_USER_IMAGES = STORAGE_BASE.child("user-pics")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_MESSAGES: DatabaseReference {
        return _REF_MESSAGES
    }
    
    var REF_USER_CURRENT: DatabaseReference {

        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        // Determine current user via UID
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var REF_POST_IMAGES: StorageReference {
        return _REF_POST_IMAGES
    }
    
    var REF_USER_IMAGES: StorageReference {
        return _REF_USER_IMAGES
    }
    
    func createFirbaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
}
