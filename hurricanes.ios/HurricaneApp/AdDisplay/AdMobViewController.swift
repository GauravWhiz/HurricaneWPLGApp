//
//  AdMobViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 31/08/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import UIKit

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

@objc protocol AdMobViewControllerDelegate: AnyObject {
    func didSuccessToReceiveAd()
    
    @objc optional func didSuccessToReceiveAd(ADHeight:CGFloat)

    func didFailToReceiveAd()

    func didAdViewPresentScreen()

    func didAdViewDismissScreen()

    @objc optional func didBannerViewDidRecordClick()
}

class AdMobViewController: UIViewController, GADBannerViewDelegate {
    var adBanner: GAMBannerView!

    var adBackgroundView: UIView?

    weak var delegate: AdMobViewControllerDelegate?
    private var AD_Height:CGFloat = (IS_IPAD ? 90 : 50)


    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // Custom initialization

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadAdMobBannerToClass(_ inputViewController: UIViewController, adUnitID: String?) {
        var adId = adUnitID
        // Initialize the banner at the bottom of the screen.
       // let origin = CGPoint(x: 0.0, y: inputViewController.view.frame.size.height - CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height)
        let origin = CGPoint(x: 0.0, y: inputViewController.view.frame.size.height - AD_Height)
        
       //self.adBanner = GAMBannerView(adSize: kGADAdSizeSmartBannerPortrait, origin: origin)
        self.adBanner = GAMBannerView(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width), origin: origin)

        if IS_IPAD {
            //let size1 = kGADAdSizeSmartBannerPortrait
            let size1 = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width)
            let size2 = GADAdSizeLeaderboard
            self.adBanner.validAdSizes = [NSValueFromGADAdSize(size1), NSValueFromGADAdSize(size2)]
        } else {
            let size1 = GADAdSizeBanner
            //let size2 = kGADAdSizeSmartBannerPortrait
            let size2 = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width)
            self.adBanner.validAdSizes = [NSValueFromGADAdSize(size1), NSValueFromGADAdSize(size2)]
        }

        if adId == nil {
            adId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "ADS_TAG") as? String
        }
        self.adBanner.adUnitID = adId
        self.adBanner.delegate = self
        inputViewController.addChild(self)
        self.adBanner.center = CGPoint(x: self.view.center.x, y: self.adBanner.center.y)
        self.adBanner.rootViewController = inputViewController
        self.view.isHidden = true
      //  self.adBanner.load(self.createRequest())
        self.adBanner.load(GAMRequest())
    }

    // Here we're creating a simple GADRequest and whitelisting the application
    // for test ads. You should request test ads during development to avoid
    // generating invalid impressions and clicks.

    func createRequest() -> GADRequest {
        let request = GADRequest()

        // Make the request for a test ad. Put in an identifier for the simulator as
        // well as any devices you want to receive test ads.
        //    NSString *simulatorUUID = [UIDevice currentDevice].identifierForVendor.UUIDString;
        //    request.testDevices = @[simulatorUUID];

        let extras = GADExtras()
       
            request.register(extras)
        
        return request
    }

    // MARK: Hide/show Add when Video Player is in full screen
    func hideBannerAD() {
        self.adBackgroundView?.isHidden = true
        self.adBanner.isHidden = true
    }

    func showBannerAD() {
        self.adBackgroundView?.isHidden = false
        self.adBanner.isHidden = false
    }

    // MARK: GADBannerViewDelegate impl
    // We've received an ad successfully.
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {// HAPP-565
       
        self.AD_Height = bannerView.frame.size.height
        
        var bottomPadding : CGFloat = 2
        var adbottomFrameforWebViewController : CGFloat = 0
        if(self.adBanner.rootViewController is LiveMapViewController || self.adBanner.rootViewController is CustomViewController) {
            bottomPadding = 0

        } else if self.adBanner.rootViewController is HurricaneWebViewController && !IS_IPAD {
            // HurricaneWebViewController
            bottomPadding  = 0//AppDefaults.getBottomPadding()
            adbottomFrameforWebViewController = 12
            //adbottomFrameforWebViewController = 0
        } else if self.adBanner.rootViewController is AlertSettingsViewController {
            bottomPadding = 0
        }
        if adBackgroundView == nil {
            if IS_IPAD {
//                self.adBackgroundView = UIView(frame: CGRect(x: 0, y: self.adBanner.rootViewController!.view.frame.size.height - (CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height), width: AppDefaults.getScreenSize().width, height: CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height))
                self.adBackgroundView = UIView(frame: CGRect(x: 0, y: self.adBanner.rootViewController!.view.frame.size.height - AD_Height, width: AppDefaults.getScreenSize().width, height:AD_Height))
            } else {
//                self.adBackgroundView = UIView(frame: CGRect(x: 0, y: self.adBanner.rootViewController!.view.frame.size.height - (CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height+bottomPadding), width: AppDefaults.getScreenSize().width, height: (CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height+bottomPadding)))
                self.adBackgroundView = UIView(frame: CGRect(x: 0, y: self.adBanner.rootViewController!.view.frame.size.height - AD_Height+bottomPadding, width: AppDefaults.getScreenSize().width, height: AD_Height+bottomPadding))
            }
        }

        if IS_IPAD {
            var frame = self.adBanner.frame
            let orientation = UIApplication.shared.statusBarOrientation
            if orientation == .landscapeLeft || orientation == .landscapeRight {
                frame.origin.y = AppDefaults.getScreenSize().height - AD_Height
                frame.origin.x = 148
            } else {
                frame.origin.y = self.adBanner.rootViewController!.view.frame.size.height - (AD_Height + adbottomFrameforWebViewController)
                frame.origin.x = (AppDefaults.getScreenSize().width -  frame.size.width) / 2
            }
            self.adBanner.frame = frame
            frame = self.adBackgroundView!.frame
            frame.origin.y = self.adBanner.frame.origin.y
            frame.size.width = AppDefaults.getScreenSize().width
            self.adBackgroundView!.frame = frame
            self.adBanner.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth, .flexibleRightMargin]
            self.adBackgroundView!.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth, .flexibleRightMargin]
        } else {
            var frame = self.adBanner.frame
            frame.origin.x = AppDefaults.getScreenSize().width / 2 - frame.size.width / 2
            frame.origin.y = self.adBanner.rootViewController!.view.frame.size.height - (AD_Height+bottomPadding + adbottomFrameforWebViewController)
            self.adBanner.frame = frame
        }
        self.adBackgroundView!.backgroundColor = UIColor.black
        self.adBanner.rootViewController!.view.addSubview(self.adBackgroundView!)
        self.adBanner.rootViewController!.view.addSubview(self.adBanner)
        self.addShadow()
        //self.delegate?.didSuccessToReceiveAd()
        self.delegate?.didSuccessToReceiveAd?(ADHeight: bannerView.frame.size.height)
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {// HAPP-565
        print("Failed to receive ad with error: \(String(describing: error.localizedDescription))")
        self.adBanner.removeFromSuperview()
        self.adBackgroundView?.removeFromSuperview()
        self.delegate?.didFailToReceiveAd()
    }

    // HAPP-565
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        self.delegate?.didAdViewPresentScreen()
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        let params = GAIDictionaryBuilder.createEvent(withCategory: "Ad", action: "Clicked", label: nil, value: nil).build() as [NSObject: AnyObject]
        tracker.send(params)

    }
  
    // HAPP-565
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        self.delegate?.didAdViewDismissScreen()
    }

    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {

        guard let method = delegate?.didBannerViewDidRecordClick else {
               // optional not implemented
               return
           }
           method()
    }

    func addShadow() {
        // Add shadow to ad unit
        if self.adBackgroundView != nil {
            let shadow = CGRect(x: self.adBackgroundView!.bounds.origin.x - 2, y: self.adBackgroundView!.bounds.origin.y - 1.5, width: self.adBackgroundView!.bounds.size.width + 4, height: 3)
            let shadowPath = UIBezierPath(rect: shadow)
            self.adBackgroundView!.layer.masksToBounds = false
            self.adBackgroundView!.layer.shadowColor = UIColor.black.cgColor
            self.adBackgroundView!.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.adBackgroundView!.layer.shadowOpacity = 0.85
            self.adBackgroundView!.layer.shadowRadius = 2
            self.adBackgroundView!.layer.shadowPath = shadowPath.cgPath
        }
    }
}
