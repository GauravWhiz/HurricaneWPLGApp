//
//  HurricaneImageCell.swift
//  Hurricane
//
//  Created by Swati Verma on 21/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

protocol HurricaneImageCellDelegate: AnyObject {
    func hurricaneImageCellDidTapped()
}

class HurricaneImageCell: UITableViewCell {
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var nameLabel: VerticalAlignedLabel!
    @IBOutlet weak var subLabel: VerticalAlignedLabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var cellButton: UIButton!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var imageLine: UIImageView!
    weak var delegate: HurricaneImageCellDelegate?

    override func awakeFromNib() {
        self.nameLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 29:25))
        self.subLabel.font = UIFont(name: kHurricaneFont_Regular, size: (IS_IPAD ? 19:13))
        self.viewLabel.font = UIFont(name: kHurricaneFont_Regular, size: (IS_IPAD ? 19:12))
        
        self.nameLabel.textColor = UIColor.white
        self.cellButton.layer.cornerRadius = 5.0
        self.categoryLabel.isHidden = true
        
        self.viewLabel.clipsToBounds = true
        self.viewLabel.layer.cornerRadius = 3.0
        self.backgroundColor = UIColor.clear
    }
}

class VerticalAlignedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        var newRect = rect
        switch contentMode {
        case .top:
            newRect.size.height = sizeThatFits(rect.size).height
        case .bottom:
            let height = sizeThatFits(rect.size).height
            newRect.origin.y += rect.size.height - height
            newRect.size.height = height
        default:
            ()
        }
        
        super.drawText(in: newRect)
    }
}
