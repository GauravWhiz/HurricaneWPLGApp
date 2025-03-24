//
//  WeatherNewsViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 13/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

class WeatherNewsViewController: GAITrackedViewController, HurricaneWebViewControllerDelegate {
    var isLandscapeRequired: Bool = false
    var isStatusBarHidden = false
    var weatherNewsUrl = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
        self.screenName = kWeatherNews
        self.view.backgroundColor = AppDefaults.colorWithHexValue(kBackgroundColor)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.showWeatherNewsPage()
    }
    override func viewDidAppear(_ animated: Bool) {
        BlueconicHelper.createBlueconicEvent(self, forPageView: "Main/WeatherNewsViewController")
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

    func showWeatherNewsPage() {
        let hurricaneWebViewController: HurricaneWebViewController = HurricaneWebViewController(nibName: "HurricaneWebViewController", bundle: nil)

        if weatherNewsUrl != "" {
            hurricaneWebViewController.url = URL(string: weatherNewsUrl)
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
