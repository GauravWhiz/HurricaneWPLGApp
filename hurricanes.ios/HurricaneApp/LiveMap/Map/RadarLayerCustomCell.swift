//
//  RadarLayerCustomCell.swift
//  Hurricane
//
//  Created by imac on 14/07/22.
//  Copyright © 2022 PNSDigital. All rights reserved.
//

import UIKit

class RadarLayerCustomCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLbl.font = UIFont.init(name: kHurricaneFont_Regular, size: CGFloat(20.0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func imageFrame() {
        imageHeight.constant = 7
        imageWidth.constant = 12
        let image = UIImage(named: "dropDown_Arrow")
        statusImage.image = image
    }

}
