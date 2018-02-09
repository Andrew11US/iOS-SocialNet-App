//
//  Constants.swift
//  SocialNet
//
//  Created by Andrew Foster on 5/9/17.
//  Copyright © 2017 Andrii Halabuda. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth

// Unique Identifier
let KEY_UID = "uid"

// Segues between View Controllers
enum Segues: String {
    case toFeed
    case toSignIn
    case toSignUp2
    case toSignUp3
    case toFeedFromSignUp
    case toMessage
    case toEditFromSettings
    case toProfile
}

// Global User reference
//let user = FIRAuth.auth()?.currentUser
