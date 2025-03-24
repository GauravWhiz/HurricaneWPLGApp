//
//  StationHeadlinesHeaderTableViewCell.swift
//  Hurricane
//
//  Created by Gaurav Purohit on 7/20/22.
//  Copyright © 2022 PNSDigital. All rights reserved.
//

import UIKit

class StationHeadlinesHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var labelHeader: UILabel!
    @IBOutlet weak var cellBackGroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.cellBackGroundView.clipsToBounds = true
        // MARK: - Corner Radius of only two side of UIViews
        self.cellBackGroundView.layer.cornerRadius = 5
        self.cellBackGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.labelHeader.font = UIFont(name: kHurricaneFont_SemiBold, size: 20.0)

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
