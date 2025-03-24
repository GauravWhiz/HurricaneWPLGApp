//
//  WxVideoCustomTableViewCell.swift
//  Hurricane
//
//  Created by Gaurav Purohit on 6/13/22.
//  Copyright © 2022 PNSDigital. All rights reserved.
//

import UIKit
import SVGKit

class WxVideoCustomTableViewCell: UITableViewCell {

    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var backgroundBGView: UIView!
    @IBOutlet weak var separatorView: UIImageView!
    var delegate:LandingPageViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.titleLabel.textColor = UIColor.white
        self.titleLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 23:20))
        self.titleLabel.numberOfLines = 0
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundBGView.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)

        let customImage = SVGKImage(named: kWXVideoAdPlayImage)!
        let hurricanePlayIconImageView = SVGKFastImageView.init(svgkImage: customImage)
        self.playImageView.addSubview(hurricanePlayIconImageView!)
        
        self.liveLabel.clipsToBounds = true
        self.liveLabel.layer.cornerRadius = 5
        
        print("Livestream allocated...")
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startStreaming), userInfo: nil, repeats: false)

    }
    
    @objc func startStreaming() {
        if AppDefaults.checkInternetConnection() == false {
            return
        }
        
        let currentPoint = CGPoint(x: 184, y: 120)
        if (self.delegate != nil) {
            self.delegate.livestreamTappedAtLocation(currentPoint)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.sizeToFit()
    }

}
