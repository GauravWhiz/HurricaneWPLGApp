//
//  TopSponsorShipTableViewCell.swift
//  Hurricane
//
//  Created by Gaurav Purohit on 1/31/23.
//  Copyright © 2023 PNSDigital. All rights reserved.
//

import UIKit

class TopSponsorShipTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var sponsorAD: GAMBannerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.labelTitle.font = UIFont(name: kHurricaneFont_SemiBold, size: 15)
        
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
