//
//  ADTableViewCell.swift
//  Hurricane
//
//  Created by Gaurav Purohit on 1/9/23.
//  Copyright © 2023 PNSDigital. All rights reserved.
//

import UIKit

class ADTableViewCell: UITableViewCell {
    
    @IBOutlet weak var myBackgroundView: UIView!
    @IBOutlet weak var seperatorLine: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
