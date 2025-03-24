//
//  StormCenterViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 15/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

class StormCenterViewController: UIViewController, CustomViewControllerDelegate {

    var stormCenterDetailArray: [AnyObject]?
    var isLandscapeRequired: Bool = false
    var needsStormsDataWithStormId:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.navigationController?.navigationBar.isHidden = false
        self.view.frame = UIScreen.main.bounds
        self.view.backgroundColor = kViewBackgroundColor
       // self.automaticallyAdjustsScrollViewInsets = false

        let customViewController: CustomViewController = CustomViewController(nibName: "CustomViewController", bundle: nil)
        customViewController.delegate = self
        customViewController.stormCenterDetailArray = self.stormCenterDetailArray
        customViewController.needsStormsDataWithStormId = self.needsStormsDataWithStormId
        self.addChild(customViewController)
        self.view!.addSubview(customViewController.view!)

        AppDefaults.getCustomViewFrame(viewFrame: &customViewController.view.frame)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BlueconicHelper.createBlueconicEvent(self, forPageView: "Main/StormCenterViewController")
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
