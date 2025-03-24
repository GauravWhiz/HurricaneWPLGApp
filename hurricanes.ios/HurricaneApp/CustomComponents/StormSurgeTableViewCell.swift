//
//  StormSurgeTableViewCell.swift
//  Hurricane
//
//  Created by Gaurav Purohit on 3/14/23.
//  Copyright © 2023 PNSDigital. All rights reserved.
//

import UIKit

class StormSurgeTableViewCell: UITableViewCell {

    @IBOutlet weak var stormSurgeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 29:24))
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
