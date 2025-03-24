//
//  HurricaneWebViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 14/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation
import WebKit

protocol HurricaneWebViewControllerDelegate: AnyObject {
    func adViewDidPresentScreen()
    func adViewDidDismissScreen()
}

class HurricaneWebViewController: UIViewController, AdMobViewControllerDelegate, WKNavigationDelegate, WKUIDelegate {
    var url: URL?
    var displayTitle: String?
    weak var delegate: HurricaneWebViewControllerDelegate?
    var webView: WKWebView?
    @IBOutlet var webContainerView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var refreshButton: UIButton!
    @IBOutlet var browserControlBGView: UIView!
    @IBOutlet var containerView: UIView!
    let progressBar = UIProgressView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewFrame()
        self.view!.addSubview(self.containerView)
        self.webContainerView.backgroundColor = kViewBackgroundColor
        if displayTitle != nil {
            AppDefaults.setNavigationBarTitle(displayTitle!, self.view)
        }

        self.configureBrowserBGView()

        let config = WKWebViewConfiguration()
        if #available(iOS 13.0, *) {
            /**
             In iOS 13 and above WKWebViews in iPad has the ability to render desktop versions of web pages.
             One of the properties they change to support this is the User-Agent.
             Therefore forcing the WKWebView to load the mobile version.
             */
            let pref = WKWebpagePreferences.init()
            pref.preferredContentMode = .mobile
            config.allowsInlineMediaPlayback = true // Force WKWebview to play video in browser player rather that defalt player
            config.defaultWebpagePreferences = pref
        }
        self.webView = WKWebView.init(frame: CGRect.zero, configuration: config)

        if self.webView != nil {
            let statusBarHeight = UIApplication.shared.statusBarHeight
            var frame: CGRect = self.webContainerView.frame
            frame.origin.y = statusBarHeight+CGFloat(navigationBarHeight)
            frame.size.height = frame.size.height - frame.origin.y
            self.webView!.frame = frame
            self.webView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.webContainerView.addSubview(self.webView!)
            self.webView!.navigationDelegate = self
            self.webView!.uiDelegate = self
            self.webView!.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
            self.webView!.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
            self.view.addSubview(progressBar)
            progressBar.frame = CGRect(x: 0, y: statusBarHeight+navigationBarHeight, width: UIScreen.main.bounds.width, height: 2)
            progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 4)
            progressBar.progressTintColor = AppDefaults.colorWithHexValue(kWebViewLoadingBgColor)
        }
        self.perform(#selector(HurricaneWebViewController.startWebViewLoad), with: nil, afterDelay: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let adUnitId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kAdMobUnitId) as? String
        if adUnitId != nil {
            self.showAdMobBannerWithAdUnitID(adUnitId!)
        }
    }

    func configureBrowserBGView() {
        self.browserControlBGView.backgroundColor = AppDefaults.colorWithHexValue(kWebViewControlsBgColor)
        let shadow: CGRect = CGRect(x: self.browserControlBGView.bounds.origin.x - 2, y: self.browserControlBGView.bounds.origin.y + self.browserControlBGView.bounds.size.height - 1.5, width: self.browserControlBGView.bounds.size.width + 4, height: 3)
        let shadowPath: UIBezierPath = UIBezierPath(rect: shadow)
        self.browserControlBGView.layer.masksToBounds = false
        self.browserControlBGView.layer.shadowColor = UIColor.black.cgColor
        self.browserControlBGView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.browserControlBGView.layer.shadowOpacity = 0.45
        self.browserControlBGView.layer.shadowRadius = 2
        self.browserControlBGView.layer.shadowPath = shadowPath.cgPath
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        self.webView?.removeObserver(self, forKeyPath: "loading")
        self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loading" && webView != nil {
            self.backButton.isEnabled = webView!.canGoBack
            self.forwardButton.isEnabled = webView!.canGoForward
        } else if keyPath == "estimatedProgress" {
            updateProgressBar(Float(self.webView!.estimatedProgress))
        }
    }

    @objc func startWebViewLoad() {
        if self.url != nil {
            _ = webView?.load(URLRequest(url: self.url!))
        }
    }

    func setViewFrame() {
        self.view.frame = UIScreen.main.bounds
        self.containerView.frame = UIScreen.main.bounds
        var frame: CGRect = self.containerView.frame
      
        let padding = AppDefaults.getBottomPadding()
        print(padding)
        
        if padding != 0.0 {
            frame.size.height = frame.size.height - 12
        }
        
        self.containerView.frame = frame
        self.view.backgroundColor = UIColor.black
    }

    // WKWebViewDelegate methods

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {

    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {

    }

    // Admob delegate methods

    func showAdMobBannerWithAdUnitID(_ adUnitId: String) {
        let adMobViewController: AdMobViewController = AdMobViewController(nibName: "AdMobViewController", bundle: nil)
        adMobViewController.delegate = self
        self.view?.addSubview(adMobViewController.view)
        adMobViewController.loadAdMobBannerToClass(self, adUnitID: adUnitId)

    }

    func didSuccessToReceiveAd() {
        var frame: CGRect = self.containerView.frame
        frame.size.height = frame.size.height - CGFloat(kAdMobAdHeight) - 2
        self.containerView.frame = frame
        self.containerView.setNeedsDisplay()
    }

    func didSuccessToReceiveAd(ADHeight:CGFloat) {
        var frame: CGRect = self.containerView.frame
        frame.size.height = frame.size.height - ADHeight - 2
        self.containerView.frame = frame
        self.containerView.setNeedsDisplay()
    }
    
    func didFailToReceiveAd() {
        /* Nothing To Do Here */
    }

    func didAdViewPresentScreen() {
        self.delegate?.adViewDidPresentScreen()
    }

    func didAdViewDismissScreen() {
        self.delegate?.adViewDidDismissScreen()
    }

    // WebView custom control methods

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        if self.webView?.canGoBack == true {
            _ = self.webView?.goBack()
        }
    }

    @IBAction func forwardButtonTapped(_ sender: AnyObject) {
        if self.webView?.canGoForward == true {
            _ = self.webView?.goForward()
        }
    }

    @IBAction func refreshButtonTapped(_ sender: AnyObject) {
        _ = self.webView?.reload()
    }

    // WKUIDelegate method

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    // Update progress bar
    func updateProgressBar(_ progress: Float) {
        if progress == 1.0 {
            progressBar.setProgress(progress, animated: true)
            UIView.animate(withDuration: 1.5, animations: { [weak self] in
                if let strongSelf = self {
                    strongSelf.progressBar.alpha = 0.0
                }
            }, completion: { [weak self] finished in
                if let strongSelf = self {
                    if finished {
                        strongSelf.progressBar.setProgress(0.0, animated: false)
                    }
                }
            })
        } else {
            if progressBar.alpha < 1.0 {
                progressBar.alpha = 1.0
            }
            progressBar.setProgress(progress, animated: (progress > progressBar.progress) && true)
        }
    }
}
