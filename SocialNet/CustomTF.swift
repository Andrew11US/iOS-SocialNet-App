//
//  CustomTF.swift
//  SocialNet
//
//  Created by Andrew Foster on 11/28/16.
//  Copyright © 2016 Andrii Halabuda. All rights reserved.
//

import UIKit

class CustomTF: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 25.0
        
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.insetBy(dx: 20, dy: 0)
        
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.insetBy(dx: 20, dy: 0)
    }
        
    

}
