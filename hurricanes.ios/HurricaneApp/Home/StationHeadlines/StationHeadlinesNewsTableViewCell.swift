//
//  WxVideoCustomTableViewCell.swift
//  Hurricane
//
//  Created by Gaurav Purohit on 6/13/22.
//  Copyright © 2022 PNSDigital. All rights reserved.
//

import UIKit
import SVGKit

class StationHeadlinesNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundBGView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLabel.textColor = UIColor.white

        if IS_IPAD {
           
            self.titleLabel.font = UIFont(name: kHurricaneFont_Medium, size: 20.0)
            self.titleLabel.numberOfLines = 2
        } else {

            self.titleLabel.font = UIFont(name: kHurricaneFont_Medium, size: 15.0)
            self.titleLabel.numberOfLines = 3
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
