//
//  MessageCell.swift
//  SocialNet
//
//  Created by Andrew on 2/11/19.
//  Copyright © 2019 Andrii Halabuda. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var data: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(message: Message) {
        self.data.text = message.content
    }

}
