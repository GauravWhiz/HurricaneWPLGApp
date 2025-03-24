//
//  AlertDetailViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 29/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation
import WebKit
import SDWebImage
import Alamofire

class AlertDetailViewController: UIViewController, AdMobViewControllerDelegate, WKNavigationDelegate {
    var notification: Notification?
    @IBOutlet var containerView: UIView!
    @IBOutlet var updateLabel: UILabel!
    @IBOutlet var lineLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var authorImageView: UIImageView!
    @IBOutlet var alertWebView: WKWebView!
    var isLandscapeRequired: Bool = false

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if !isLandscapeRequired {
            return [.portrait, .portraitUpsideDown]
        } else {
            return .all
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.view.frame = UIScreen.main.bounds
        self.setCustomAppearence()
        alertWebView.navigationDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let adUnitId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kAdMobUnitId) as? String
        if adUnitId != nil {
            self.showAdMobBannerWithAdUnitID(adUnitId!)
        }

        self.setCustomText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showAdMobBannerWithAdUnitID(_ adUnitId: String) {
        let adMobViewController: AdMobViewController = AdMobViewController(nibName: "AdMobViewController", bundle: nil)
        adMobViewController.delegate = self
        self.view?.addSubview(adMobViewController.view)
        adMobViewController.loadAdMobBannerToClass(self, adUnitID: adUnitId)

    }

    func didSuccessToReceiveAd() {
        var frame: CGRect = self.containerView.frame
        frame.size.height = frame.size.height - (CGFloat(kAdMobAdHeight)+AppDefaults.getBottomPadding())
        self.containerView.frame = frame
        self.containerView.setNeedsDisplay()
    }
    
    func didSuccessToReceiveAd(ADHeight:CGFloat) {
        var frame: CGRect = self.containerView.frame
        frame.size.height = frame.size.height - (ADHeight+AppDefaults.getBottomPadding())
        self.containerView.frame = frame
        self.containerView.setNeedsDisplay()
    }

    func didFailToReceiveAd() {
        /* Nothing To Do Here */
    }

    func didAdViewPresentScreen() {
        self.isLandscapeRequired = true
    }

    func didAdViewDismissScreen() {
        self.isLandscapeRequired = false
    }

    func setCustomAppearence() {
        self.setViewFrame(viewFrame: &self.containerView.frame)
        self.view.backgroundColor = AppDefaults.colorWithHexValue(Int(kBackgroundColor))
        self.updateLabel.textColor = UIColor.white
        self.updateLabel.numberOfLines = 0
        self.updateLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 30 : 20))
        self.lineLabel.backgroundColor = AppDefaults.colorWithHexValue(Int(kLabelGreenColorDark))
        self.durationLabel.textColor = AppDefaults.colorWithHexValue(Int(kLabelGreenColorDark))
        self.durationLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 26 : 13))
        self.setAlertWebViewAppeaence()
    }

    func setAlertWebViewAppeaence() {
        self.alertWebView.backgroundColor = UIColor.clear
        for subView: UIView in self.alertWebView.subviews {
            if subView is UIScrollView {
                for shadowView: UIView in subView.subviews {
                    if shadowView is UIImageView {
                        shadowView.isHidden = true
                    }
                }
            }
        }
    }

    func setCustomText() {
        if self.notification != nil {
            if self.notification?.met != nil {
                self.updateLabel.text = String(format: "Update from\n%@", (self.notification?.met)!)
            }

            if self.notification!.text != nil {
                let myDescriptionHTML: String = "<html> \n" +
                    "<head> \n" +
                    "<style type=\"text/css\"> \n" +
                    "body {font-family: \"\("Georgia-Italic")\"; font-size: \(Int((IS_IPAD ? 32 : 16))); color: #ffffff;}\n" +
                    "</style> \n" +
                    "</head> \n" +
                    "<body style=\"background-color:011b2d\">\(self.notification!.text!)</body> \n" +
                "</html>"
                self.alertWebView.loadHTMLString(AppDefaults.getHeaderForWKWebView()! + myDescriptionHTML, baseURL: nil)
            }

            self.alertWebView.scrollView.backgroundColor = UIColor.clear

            let timeText = self.notification!.timesince
            if timeText != nil {
                self.durationLabel.text = String(format: "Posted %@ ago", timeText!).uppercased()
            }
            let imageUrlStr = self.notification!.imageURL
            if imageUrlStr != nil {
                let imageUrl = URL(string: imageUrlStr!)
                if imageUrl != nil {
                    self.authorImageView.sd_setImage(with: imageUrl)
                }
            }
        }
    }

    func setViewFrame(viewFrame: inout CGRect) {
        let topPaddingInsets = AppDefaults.getTopPadding()
        if topPaddingInsets > 0.0 {
            viewFrame.origin.y = viewFrame.origin.y + topPaddingInsets + kTopPadding
            viewFrame.size.height = viewFrame.size.height - (topPaddingInsets+kTopPadding)
        } else {
            viewFrame.origin.y = viewFrame.origin.y + (kTopPadding*2)
            viewFrame.size.height = viewFrame.size.height - (kTopPadding*2)
        }
    }
}
extension UIImageView {
    public func imageFromUrl(url: URL) {
     
        AF.request( url.absoluteString,method: .get).response { response in

           switch response.result {
            case .success(let responseData):
                self.image = UIImage(data: responseData!, scale:1)
               
            case .failure(let error):
                print("error--->",error)
                self.imageFromUrl(url: url)
            }
            
            MBProgressHUD.hide(for: self, animated: true)
        }
    }
}
