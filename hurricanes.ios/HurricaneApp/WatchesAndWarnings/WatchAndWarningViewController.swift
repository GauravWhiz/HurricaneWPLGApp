//
//  WatchAndWarningViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 15/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

class WatchAndWarningViewController: UIViewController, CustomViewControllerDelegate {

    var watchAndWarningsDetailArray: [AnyObject]?
    var isLandscapeRequired: Bool = false
    var isWatchesAndWarnings: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.view.frame = UIScreen.main.bounds
        self.view.backgroundColor = kViewBackgroundColor
        //self.automaticallyAdjustsScrollViewInsets = false
        let customViewController: CustomViewController = CustomViewController(nibName: "CustomViewController", bundle: nil)
        customViewController.screenName = kWatchesAndWarnings
        customViewController.delegate = self
        customViewController.isWatchesAndWarnings = self.isWatchesAndWarnings
        customViewController.stormCenterDetailArray = self.watchAndWarningsDetailArray
        self.addChild(customViewController)
        self.view!.addSubview(customViewController.view!)
        AppDefaults.setNavigationBarTitle(kWatchesAndWarnings, self.view)
        AppDefaults.getCustomViewFrame(viewFrame: &customViewController.view.frame)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    override func viewDidAppear(_ animated: Bool) {
        BlueconicHelper.createBlueconicEvent(self, forPageView: "Main/WatchAndWarningViewController")
    }
    override func viewWillDisappear(_ animated: Bool) {
      
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if !isLandscapeRequired {
            return [.portrait, .portraitUpsideDown]
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imageViewDidDisplay() {
        self.isLandscapeRequired = true
    }

    func imageViewDidClose() {
        self.isLandscapeRequired = false
        self.navigationController?.isNavigationBarHidden = false
    }

    func adViewDidPresentScreen() {
        self.isLandscapeRequired = true
    }

    func adViewDidDismissScreen() {
        self.isLandscapeRequired = false
    }
    
    func setNavigationTitle(pTitle:String) {
        AppDefaults.setNavigationBarTitle(pTitle, self.view)
    }
}
