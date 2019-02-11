//
//  Message.swift
//  SocialNet
//
//  Created by Andrew on 2/11/19.
//  Copyright © 2019 Andrii Halabuda. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class Message {
    
    private var _content: String!
    private var _from: String!
    private var _messageKey: String!
    
    var content: String {
        return _content
    }
    
    var from: String {
        return _from
    }
    
    var messageKey: String {
        return _messageKey
    }
    
    init(content: String, from: String, messageKey: String) {
        self._content = content
        self._from = from
        self._messageKey = messageKey
    }
    
    init(messageKey: String, messageData: Dictionary<String, AnyObject>) {
        self._messageKey = messageKey
        
        if let content = messageData["content"] as? String {
            self._content = content
        }
        
        if let from = messageData["from"] as? String {
            self._from = from
        }
        
    }
    
}
