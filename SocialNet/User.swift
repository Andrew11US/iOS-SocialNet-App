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
    private var _userPicUrl: String!
    private var _userId: String!
    private var _name: String!
    private var _userRef: DatabaseReference!
    private var _messageKeys: Dictionary<String, String>!
    
    var username: String {
        return _username
    }
    
    var userPicUrl: String {
        return _userPicUrl
    }
    
    var userId: String {
        return _userId
    }
    
    var name: String {
        return _name
    }
    
    var messageKeys: Dictionary<String, String> {
        return _messageKeys
    }
    
    init(username: String, name: String, userPicUrl: String) {
        self._username = username
        self._name = name
        self._userPicUrl = userPicUrl
    }
    
    init(userId: String, userData: Dictionary<String, AnyObject>) {
        self._userId = userId
        
        if let username = userData["username"] as? String {
            self._username = username
        }
        
        if let name = userData["name"] as? String {
            self._name = name
        }
        
        if let userPicUrl = userData["userPicUrl"] as? String {
            self._userPicUrl = userPicUrl
        }
    }
    
    init(userID: String, messageKeys: Dictionary<String, String>) {
        self._userId = userID
        self._messageKeys = messageKeys
    }
    
//    convenience init() {
//        
//        _userId = ""
//        _messageKeys = [:]
//    }
    
}
