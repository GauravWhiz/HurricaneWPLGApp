//
//  HurricaneWidgetCell.swift
//  Hurricane
//
//  Created by Sachin Ahuja on 01/09/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation
import UIKit

class HurricaneWidgetCell: UITableViewCell {
    @IBOutlet weak var hurricaneName: UILabel!
    @IBOutlet weak var hurricaneCategory: UILabel!
    @IBOutlet weak var hurricaneCategoryBackground: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var hurricaneMovement: UILabel!
    var bottomBorder: CALayer?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func awakeFromNib() {
        self.hurricaneName.font = UIFont(name: "Helvetica-Bold", size: 22)
        self.hurricaneName.lineBreakMode = .byTruncatingTail

        self.hurricaneMovement.font = UIFont(name: "Helvetica", size: 14)
        self.hurricaneMovement.lineBreakMode = .byTruncatingTail

        if #available(iOSApplicationExtension 10.0, *) {
            self.hurricaneName.textColor = UIColor.black
            self.hurricaneMovement.textColor = UIColor.black
        } else {
            self.hurricaneName.textColor = UIColor.white
            self.hurricaneMovement.textColor = UIColor.white
        }

        self.hurricaneName.minimumScaleFactor = 0.7
        self.hurricaneName.adjustsFontSizeToFitWidth = true

        self.hurricaneMovement.minimumScaleFactor = 0.5
        self.hurricaneMovement.adjustsFontSizeToFitWidth = true

        self.hurricaneCategory.font = UIFont(name: "Cabin-Bold", size: 26)
        self.hurricaneCategory.textColor = UIColor.white
        self.hurricaneCategoryBackground.backgroundColor = UIColor.red
        self.hurricaneCategoryBackground.layer.cornerRadius = self.hurricaneCategoryBackground.frame.size.width / 2
        self.selectionStyle = .none
        self.bottomBorder = CALayer()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            self.alpha = 0.5
        } else {
            self.alpha = 1.0
        }
    }
}
