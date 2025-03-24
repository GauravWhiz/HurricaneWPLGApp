//
//  UpgradeViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 13/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import UIKit

class UpgradeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.navigationController != nil {
            if Float(UIScreen.main.bounds.size.width) == kIphone6Width {
                self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: kNavigationBarImageForIphone6), for: .default)
            } else {
                self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: kNavigationBarImage), for: .default)
            }
            self.navigationController!.navigationBar.alpha = 1.0
            self.navigationController!.navigationBar.isTranslucent = false
        }
        self.loadUpgradeView()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadUpgradeView() {
        ApplicationConfig.sharedInstance().setUpdateButtonTextColor(UIColor.white)
        ApplicationConfig.sharedInstance().setTextFontSize(16.0)
        ApplicationConfig.sharedInstance().setHeaderFontSize(32.0)
        ApplicationConfig.sharedInstance().forceUpdate(kHurricaneFont_SemiBold, withTitleFont: kHurricaneFont_SemiBold, bgColor: AppDefaults.colorWithHexValue(Int(kBackgroundColor)), headerColor: UIColor.white, textColor: AppDefaults.colorWithHexValue(Int(kSubHeaderColor)), buttonBGColor: AppDefaults.colorWithHexValue(Int(kLabelGreenColorDark)), buttonFont: kHurricaneFont_Medium)
        self.addChild(ApplicationConfig.sharedInstance())
        self.view!.addSubview(ApplicationConfig.sharedInstance().view!)
    }

}
