//
//  HurricaneImageCell.swift
//  Hurricane
//
//  Created by Swati Verma on 21/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

class SailthruMessageCell: UITableViewCell {
    @IBOutlet weak var stormImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cellButton: UIButton!
    @IBOutlet weak var txtVDiscussion: UITextView!
    @IBOutlet weak var seperatorLine: UIImageView!

    override func awakeFromNib() {
        self.nameLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 29:23))
        self.nameLabel.backgroundColor = UIColor.clear
        self.nameLabel.textColor = UIColor.white
        self.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
        
        self.txtVDiscussion.textColor = UIColor.white
        self.txtVDiscussion.font = UIFont(name: kHurricaneFont_Medium, size: (IS_IPAD ? 22 : 16))
        self.txtVDiscussion.textContainer.lineBreakMode = .byTruncatingTail
        self.txtVDiscussion.textContainer.maximumNumberOfLines = 0
      
        self.cellButton.layer.cornerRadius = 5
    }
}
