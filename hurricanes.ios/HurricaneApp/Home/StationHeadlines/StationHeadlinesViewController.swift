//
//  StationHeadlinesViewController.swift
//  Hurricane
//
//  Created by Gaurav Purohit on 7/25/22.
//  Copyright © 2022 PNSDigital. All rights reserved.
//

import UIKit

class StationHeadlinesViewController: GAITrackedViewController, HurricaneWebViewControllerDelegate {

    private var isLandscapeRequired: Bool = false
    private var isStatusBarHidden = false
    var stationHeadlinesURL: String!
    var screenTitle:String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view from its nib.
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidRotate), name: UIDevice.orientationDidChangeNotification, object: nil)

        self.screenName = self.screenTitle

        self.view.backgroundColor = AppDefaults.colorWithHexValue(kBackgroundColor)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.showStationHeadlinesPage()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BlueconicHelper.createBlueconicEvent(self, forPageView: "Main/StationHeadlinesViewController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.takeSnapShotOfView()
    }

    @objc func videoDidRotate() {
        if !UIDevice.current.orientation.isLandscape {
            isStatusBarHidden = false
            self.setNeedsStatusBarAppearanceUpdate()
            self.view.setNeedsLayout()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func showStationHeadlinesPage() {

        let hurricaneWebViewController: HurricaneWebViewController = HurricaneWebViewController(nibName: "HurricaneWebViewController", bundle: nil)

        if stationHeadlinesURL != nil {
            hurricaneWebViewController.url = URL(string: stationHeadlinesURL!)
            hurricaneWebViewController.displayTitle = String(self.screenName)
            var frm = self.view.frame

            let padding = AppDefaults.getBottomPadding()
            print(padding)
            
            if padding != 0.0 {
                frm.origin.y = self.view.safeAreaInsets.top + 12
            }
            
            hurricaneWebViewController.view.frame = frm
            hurricaneWebViewController.delegate = self
            self.addChild(hurricaneWebViewController)
            self.view!.addSubview(hurricaneWebViewController.view!)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if !isLandscapeRequired {
            return [.portrait, .portraitUpsideDown]
        } else {
            return .all
        }
    }

    func adViewDidPresentScreen() {
        self.isLandscapeRequired = true
    }

    func adViewDidDismissScreen() {
        self.isLandscapeRequired = false
    }

    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }

}
