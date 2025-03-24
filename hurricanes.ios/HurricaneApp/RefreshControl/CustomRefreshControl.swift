//
//  CustomRefreshControl.swift
//  Hurricane
//
//  Created by Swati Verma on 28/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

class CustomRefreshControl: UIRefreshControl {
    convenience override init(frame: CGRect) {
        self.init(frame: frame)
            // Initialization code
            self.tintColor = AppDefaults.colorWithHexValue(Int(kPullToRefreshColor))
            self.attributedTitle = NSAttributedString(string: "pull to Refresh")
        }

}
