//
//  InfoNotAvailableViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 16/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

class InfoNotAvailableViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!

    let kNoInformationTitle = "Not Available"
    let kNoInformationDescription = "Information related to this Notification is no longer available."

    let kTitleLabelFontSize = IS_IPAD ? 40 : 20.23
    let kdescriptionLabelFontSize = IS_IPAD ? 36 : 18.11

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.view.frame = UIScreen.main.bounds
        self.setCustomAppearence()
    }

    func setCustomAppearence() {
        AppDefaults.getCustomViewFrame(viewFrame: &self.containerView.frame)
        self.view.backgroundColor = AppDefaults.colorWithHexValue(Int(kBackgroundColor))
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.numberOfLines = 0
        self.titleLabel.font = UIFont(name: kHurricaneFont_Medium, size: CGFloat(kTitleLabelFontSize))
        self.lineLabel.backgroundColor = AppDefaults.colorWithHexValue(Int(kLabelGreenColorDark))
        self.descriptionLabel.textColor = UIColor.white
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.font = UIFont(name: kHurricaneFont_Regular, size: CGFloat(kdescriptionLabelFontSize))
        self.titleLabel.text = kNoInformationTitle
        self.descriptionLabel.text = kNoInformationDescription
        self.titleLabel.sizeToFit()
        self.descriptionLabel.sizeToFit()
    }

    @IBAction func homeButtonTapped(_ sender: AnyObject) {
        self.navigationController!.popToRootViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
