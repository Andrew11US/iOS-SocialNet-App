//
//  User.swift
//  SocialNet
//
//  Created by Andrew Foster on 5/13/17.
//  Copyright © 2017 Andrii Halabuda. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class User {
    private var _username: String!
    private var _userImageUrl: String!
    private var _userKey: String!
    private var _userRef: FIRDatabaseReference!
    
    var username: String {
        return _username
    }
    
    var userImageUrl: String {
        return _userImageUrl
    }
    
    var userKey: String {
        return _userKey
    }
    
    init(username: String, userImageUrl: String) {
        self._username = username
        self._userImageUrl = userImageUrl
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>) {
        self._userKey = userKey
        
        if let username = userData["username"] as? String {
            self._username = username
        }
        
        if let userImageUrl = userData["userImageUrl"] as? String {
            self._userImageUrl = userImageUrl
        }
        
        _userRef = DataService.ds.REF_USERS.child(_userKey)
        
    }
    
}
