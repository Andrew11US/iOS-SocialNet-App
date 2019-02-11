//
//  ConnectCell.swift
//  SocialNet
//
//  Created by Andrew on 2/11/19.
//  Copyright © 2019 Andrii Halabuda. All rights reserved.
//

import UIKit

class ConnectCell: UICollectionViewCell {
    
    @IBOutlet weak var username: UILabel!
    
    func configureCell(username: String) {
        self.username.text = username
    }
    
}
