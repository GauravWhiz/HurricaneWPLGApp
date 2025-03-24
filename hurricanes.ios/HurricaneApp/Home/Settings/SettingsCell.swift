//
//  SettingsCell.swift
//  Hurricane
//
//  Created by Sachin Ahuja on 13/06/18.
//  Copyright © 2018 Graham Digital. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cellButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 21:25))
        self.nameLabel.backgroundColor = UIColor.clear
        self.nameLabel.textColor = UIColor.white
        self.nameLabel.text = "Settings"
        self.cellButton.backgroundColor = UIColor(red: (128.0 / 255.0), green: (128.0 / 255.0), blue: (128.0 / 255.0), alpha: 1.0)
        self.cellButton.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
