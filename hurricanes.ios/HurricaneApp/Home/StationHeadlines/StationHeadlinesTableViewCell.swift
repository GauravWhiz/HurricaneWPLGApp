//
//  StationHeadlinesTableViewCell.swift
//  Hurricane
//
//  Created by Gaurav Purohit on 7/20/22.
//  Copyright © 2022 PNSDigital. All rights reserved.
//

import UIKit

class StationHeadlinesTableViewCell: UITableViewCell {

    @IBOutlet weak var cellBackGroundView: UIView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var separatorImageLine: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.newsTitle.font = UIFont(name: kHurricaneFont_Regular, size: 13.0)

        if IS_IPAD {
            self.cellBackGroundView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.70).isActive = true
        } else {
            self.cellBackGroundView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.71).isActive = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
