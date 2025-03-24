//
//  TropicWatchViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 15/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

class TropicWatchViewController: UIViewController, CustomViewControllerDelegate {

    var tropicWatchDetailArray: [AnyObject]?
    var isLandscapeRequired: Bool = false
    var isTropicsWatch: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.view.frame = UIScreen.main.bounds
        self.view.backgroundColor = kViewBackgroundColor
        //self.automaticallyAdjustsScrollViewInsets = false

        let customViewController: CustomViewController = CustomViewController(nibName: "CustomViewController", bundle: nil)
        customViewController.delegate = self
        customViewController.isTropicsWatch = self.isTropicsWatch
        customViewController.stormCenterDetailArray = self.tropicWatchDetailArray
        self.addChild(customViewController)
        self.view!.addSubview(customViewController.view!)

        AppDefaults.getCustomViewFrame(viewFrame: &customViewController.view.frame)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BlueconicHelper.createBlueconicEvent(self, forPageView: "Main/TropicWatchViewController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.takeSnapShotOfView()
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
        AppDefaults.setNavigationBarTitle("Tropics Watch", self.view)
    }
}
