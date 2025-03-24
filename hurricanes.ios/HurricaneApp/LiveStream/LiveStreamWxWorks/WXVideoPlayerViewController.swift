//
//  VideoPlayerViewController.swift
//  Sierra
//
//  Created by Swati Verma on 17/08/17.
//  Copyright © 2017 Graham Digital. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleInteractiveMediaAds
import Reachability

protocol VideoPlayerViewControllerDelegate: NSObjectProtocol {
    func videoPlayerViewDidDisplay()
    func videoPlayerViewDidClose()
    func videoPlayerPresentFullScreen()
    func videoPlayerDismissFullScreen()
    func loadingIndicatorDismiss()
}

class WXVideoPlayerViewController: UIViewController, IMAAdsLoaderDelegate, IMAAdsManagerDelegate, AVPlayerViewControllerDelegate,AVPictureInPictureControllerDelegate {
   
    weak var delegate: VideoPlayerViewControllerDelegate?
    var contentPlayer: AVPlayer?
    let playerViewController = AVPlayerViewController()
    @IBOutlet weak var videoPlayIconView: UIView!
    var playURL: String?
    var category: String = ""
    var navTitle: String? = ""
    var articleTitle: String? = ""
    var shouldPersistPlayer: Bool = false
    var isAdPlayComplete = false
    var videoFrameSize = CGSize.zero

    var timer: Timer?
    var isPlayStarted: Bool = false
    var isSeeking: Bool = false
    var duration: Double = 0.0
    var isPlayerAutoPaused: Bool = false
    var isPlayerPaused: Bool = false
    var isStatusBarHidden: Bool = false
    var isSubtitleDisplayed = false
    var playerLayer: AVPlayerLayer?
    var isStatusObserverAdded = false
    var isTimeControlsStatusObserverAdded = false
    var isLiveVideo = false
    var adsLoader: IMAAdsLoader?
    var adsManager: IMAAdsManager?
    var shouldResumePlayer = false
    var isVideoFullscreen = false
    var smallVideoFrame: CGRect!
    var adStartedPlaying = false
    var isPlayerPausedForPushingViewController = false
    var delegateLandingPageVC:LandingPageViewController!

    let fullScreenSize = 70
    private var iOS16Landscape = false
    
    // PiP objects.
    var pictureInPictureProxy: IMAPictureInPictureProxy?
    var imaAVPlayerVideoDisplay:IMAAVPlayerVideoDisplay?
    var pictureInPictureController:AVPictureInPictureController?
    var isPipIsActive = false
    
    private var timerLoadingStop:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationItem.title = self.navTitle
        self.view.backgroundColor = UIColor.black
        let statusBarHeight = UIApplication.shared.statusBarHeight
        videoFrameSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-statusBarHeight)
        shouldPersistPlayer = false

        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
            }
        } catch let error as NSError {
            NSLog("Unresolved error \(String(describing: error)), \(error.userInfo)")
            var errorStr = "\(String(describing: error))"
            errorStr = errorStr.replacingOccurrences(of: " ", with: "_")
            
            var errorInfo = "\(error.userInfo)"
            errorInfo = errorInfo.replacingOccurrences(of: " ", with: "_")
            
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
              AnalyticsParameterItemID: "\(errorStr)",
              AnalyticsParameterItemName: "\(errorInfo)",
              AnalyticsParameterContentType: "Livestream"
            ])
           
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(networkConnectionChanged(_:)), name: NSNotification.Name(rawValue: "kReachabilityChangedNotification"), object: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil)
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "kReachabilityChangedNotification"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !shouldPersistPlayer {
            delegate?.videoPlayerViewDidDisplay()
            
            DispatchQueue.main.async {
                if AppDefaults.checkInternetConnection() == true {
                    self.setupAdsLoader()
                    self.drawPlayer()
                    self.requestAds()
                }
            }
        } else {
            shouldPersistPlayer = false
            if !self.isPlaying() && isPlayerAutoPaused {
                self.playerViewController.player?.play()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }

    @objc func device_rotated(notification: Notification) {

        if #available(iOS 16.0, *) {

            self.setNeedsUpdateOfSupportedInterfaceOrientations()
            self.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()

            switch UIDevice.current.orientation {
                case .landscapeLeft:
                 
                    self.iOS16Landscape = true
                    break
                case .landscapeRight:
                 
                    self.iOS16Landscape = true
                    break
                case .portrait:
                  
                    self.iOS16Landscape = false
                    break
                case .portraitUpsideDown:
                
                    self.iOS16Landscape = true
                    break
                default:
                    print("Default")
                }

        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {

        if object as? AVPlayer == contentPlayer && (keyPath == "status") {
            if contentPlayer?.status == .readyToPlay {

                if isPlayerAutoPaused {
                    //contentPlayer?.pause()
                    self.playerViewController.player?.pause()
                }

                if !isPlayStarted {
                    trackEventForAnalytics(action: "playerPlay")
                    
                    let playURLLocal = playURL ?? "NoUrlFound"
                    
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                      AnalyticsParameterItemID: "LivestreamURL",
                      AnalyticsParameterItemName: "\(playURLLocal)",
                      AnalyticsParameterContentType: "ActuaURL"
                    ])
                    
                    isPlayStarted = true
                    var duration: TimeInterval?
                    if let duration1 = contentPlayer?.currentItem?.asset.duration {
                        duration = TimeInterval(CMTimeGetSeconds(duration1))
                    }
                    if duration?.isNaN ?? false || (duration == 0.0) {
                        timer?.invalidate()
                        setToolBarForLivestream()
                    } else {
                       
                    }
                }
                contentPlayer?.removeObserver(self, forKeyPath: "status")
                isStatusObserverAdded = false
            } else if contentPlayer?.status == .failed {
                // something went wrong. player.error should contain some information
                contentPlayer?.removeObserver(self, forKeyPath: "status")
                isStatusObserverAdded = false
            }
        } else if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
                    let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
                    let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
                    if newStatus != oldStatus {
                        DispatchQueue.main.async {[weak self] in
                            if newStatus == .playing || newStatus == .paused {
                                
                                self?.timerLoadingStop?.invalidate()
                                
                                MBProgressHUD.hide(for: self!.view, animated: true)
                               
                                if (self!.isTimeControlsStatusObserverAdded) {
                                    self!.contentPlayer?.removeObserver(self!, forKeyPath: "timeControlStatus")
                                    self!.isTimeControlsStatusObserverAdded = false
                                }
                              
                            } else {
                                
                                self?.timerLoadingStop = Timer.scheduledTimer(timeInterval: 10.0, target: self!, selector: #selector(self?.stopPlayerStreamIsNotResponding), userInfo: nil, repeats: false)
                                
                                let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self!.view, animated: true)
                                hud.labelText = kHUDLabelText
                            }
                        }
            }
        }
    }
    
    @objc func stopPlayerStreamIsNotResponding() {
        DispatchQueue.main.async {
            if self.view == nil || self.isTimeControlsStatusObserverAdded == false {
                return
            }
            
            self.contentPlayer?.pause()
            MBProgressHUD.hide(for: self.view, animated: true)
            self.isTimeControlsStatusObserverAdded = false
            self.contentPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
        }
    }
    
    //MARK: - PIP methods
    func playerViewController(_: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator: UIViewControllerTransitionCoordinator) {
        print("full screen")
        self.isVideoFullscreen = true
        
        willBeginFullScreenPresentationWithAnimationCoordinator.animate(alongsideTransition: nil) { transitionContext in
            self.playerViewController.player?.play()
        }
    }
    func playerViewController(_: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator: UIViewControllerTransitionCoordinator) {
        print("normal screen")
        self.isVideoFullscreen = false
        shouldPersistPlayer = true
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        
        self.isPipIsActive = false
        
        if (isAdPlayComplete && !self.isVideoFullscreen) {
            self.delegateLandingPageVC.livestreamPiPClose(completionHandler: completionHandler)
        }
    }
    
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("playerViewControllerWillStartPictureInPicture")
        self.isPipIsActive = true
        
        if (isAdPlayComplete) {
            
            if (isAdPlayComplete) {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
                    //Animations
                    self.delegateLandingPageVC.livestreamPiPStart()
                }) { (finished) in
                    self.playerViewController.player?.play()
                }
            }
        }
        
    }
    
    func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        self.isPipIsActive = false
        
        if (isAdPlayComplete) {
            self.delegateLandingPageVC.livestreamPiPClose(completionHandler: nil)
        }
    }

    //MARK: - Notifications
    @objc func playerItemDidReachEnd() {
        if self.isAdPlayComplete {
            self.trackEventForAnalytics(action: "playerPlayEnd")
        }
    }
    
    func setToolBarForLivestream() {
        isLiveVideo = true
    }

    func isPlaying() -> Bool {
        if contentPlayer != nil {
            return (contentPlayer?.rate != 0) && (contentPlayer?.error == nil)
        } else {
            return false
        }
    }

    @objc func resumePlay() {
        if !isPlayerPaused && self.isAdPlayComplete == true && self.isPlayerPausedForPushingViewController == false {
            self.playerViewController.player?.play()
        }
    }

    func drawPlayer() {
        var contentURL: URL?
        if self.playURL != nil {
            print("No hlsURL prsent for the livestream")

        }
        contentURL = URL(string: self.playURL ?? "")
        if let contentURL = contentURL {
            self.contentPlayer = AVPlayer(url: contentURL)
        }

        playerLayer = AVPlayerLayer(player: playerViewController.player)
        // Size, position, and display the AVPlayer.
        if let playerLayer = playerLayer {
            view.layer.addSublayer(playerLayer)
        }
        
        self.playerViewController.player = self.contentPlayer
        playerViewController.delegate = self
        playerViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        playerViewController.allowsPictureInPicturePlayback = true
        playerViewController.exitsFullScreenWhenPlaybackEnds = false
        if #available(iOS 14.2, *) {
            playerViewController.canStartPictureInPictureAutomaticallyFromInline = true
        } else {
            // Fallback on earlier versions
        }
        playerViewController.showsPlaybackControls = true
        self.addChild(playerViewController)
        self.view.addSubview(playerViewController.view)
        
        self.addMetaDataForPlayerCurrentItem()
        
        self.playerViewController.player?.play()
        
        // Set ourselves up for PiP.
        self.imaAVPlayerVideoDisplay = IMAAVPlayerVideoDisplay(avPlayer: self.contentPlayer!)
        self.pictureInPictureProxy = IMAPictureInPictureProxy(avPlayerViewControllerDelegate: self)
        self.pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer!)

        Timer.scheduledTimer(withTimeInterval: 0.50, repeats: false) { (_) in
               // TODO: - whatever you want
            
            self.contentPlayer?.addObserver(self, forKeyPath: "status", options: [], context: nil)
            self.isStatusObserverAdded = true
            
        }
    }
    
    func addMetaDataForPlayerCurrentItem() {
        
        if (self.playerViewController.player == nil) || (self.playerViewController.player?.currentItem == nil) {
            return;
        }
        
        let itemTitle = AVMutableMetadataItem()
        itemTitle.keySpace = .common
        itemTitle.key = AVMetadataKey.commonKeyTitle as any NSCopying & NSObjectProtocol
        itemTitle.value = self.delegateLandingPageVC.selectedLiveStreamObject["title"] as? String as (any NSCopying & NSObjectProtocol)?
        
        let itemArtist = AVMutableMetadataItem()
        itemArtist.keySpace = .common
        itemArtist.key = AVMetadataKey.commonKeyArtist as any NSCopying & NSObjectProtocol
        itemArtist.value = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String as (any NSCopying & NSObjectProtocol)?
        
        let itemArtwork = AVMutableMetadataItem()
        itemArtwork.keySpace = .common
        itemArtwork.key = AVMetadataKey.commonKeyArtwork as any NSCopying & NSObjectProtocol
        let itemImage = UIImage(named: "AppLogo")
        if itemImage != nil {
            itemArtwork.value = itemImage!.pngData() as (any NSCopying & NSObjectProtocol)?
        }
        
        
        self.playerViewController.player?.currentItem!.externalMetadata = [itemTitle,itemArtist, itemArtwork]
    }

    func setupAdsLoader() {
        
        let imaSetting = IMASettings()
        imaSetting.enableBackgroundPlayback = true
        adsLoader = IMAAdsLoader(settings: imaSetting)
        adsLoader?.delegate = self
    }

    func requestAds() {
        // Create an ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: view, viewController: self)// SIE-891
        let adTag = getAdTag()
        guard let contentPlayer = self.contentPlayer else { return }
        guard let pictureInPictureProxy = self.pictureInPictureProxy else { return }
        
        if adTag.count > 0 {

            let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.labelText = kHUDLabelText

            adTag.withCString {
                let adURL = String(format: self.getAdURL(), $0)
                // Create an ad request with our ad tag, display container, and optional user context.
                let request = IMAAdsRequest(adTagUrl: adURL, adDisplayContainer: adDisplayContainer, avPlayerVideoDisplay: self.imaAVPlayerVideoDisplay!, pictureInPictureProxy: pictureInPictureProxy, userContext: nil)
                
                adsLoader?.requestAds(with: request)
            }
        } else {
            self.playerViewController.player?.play()
            self.isAdPlayComplete = true
        }
    }
    
   

    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        let adsManager = adsLoadedData.adsManager
        if adsManager != nil {

            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = AppDefaults.colorWithHexValue(Int(kBarButtonColor))

            self.adsManager = adsLoadedData.adsManager
            self.adsManager?.delegate = self
            // Create ads rendering settings to tell the SDK to use the in-app browser.
            let adsRenderingSettings = IMAAdsRenderingSettings()
            adsRenderingSettings.linkOpenerPresentingController = delegateLandingPageVC
            // Initialize the ads manager.
            self.adsManager?.initialize(with: adsRenderingSettings)

            self.delegate?.loadingIndicatorDismiss()
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.playerViewController.player?.play()
            self.isAdPlayComplete = true
        }
    }

    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        // Something went wrong loading ads. Log the error and play the content.
        self.playerViewController.player?.play()
        isAdPlayComplete = true
        MBProgressHUD.hide(for: self.view, animated: true)
        self.delegate?.loadingIndicatorDismiss()
    }

    func webOpenerWillClose(inAppBrowser webOpener: NSObject!) {
        self.adsManager?.resume()
    }

    func stopAndRemovePlayer() {
        print("stopAndRemovePlayer Enter")
        timer?.invalidate()
        removePlayer()
        contentPlayer = nil
        print("stopAndRemovePlayer Exit")
    }

    func removePlayer() {
        self.playerViewController.player?.pause()
        if isStatusObserverAdded {
            if contentPlayer?.observationInfo != nil {
                contentPlayer?.removeObserver(self, forKeyPath: "status")
                isStatusObserverAdded = false;
            }
        }
        
        if (self.isTimeControlsStatusObserverAdded) {
            contentPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
            self.isTimeControlsStatusObserverAdded = false;
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
        } catch {
        }
        if adsManager != nil {
            destroyAdManager()
        }
        contentPlayer?.replaceCurrentItem(with: nil)
        contentPlayer = nil
       // playerLayer?.removeFromSuperlayer()

        if !shouldPersistPlayer {
            delegate?.videoPlayerViewDidClose()
        }
    }

    func destroyAdManager() {
        adsManager?.delegate = nil
        adsManager?.destroy()
        adsManager = nil
    }

    @objc func handleCloseButtonSingleTap(_ recognizer: UITapGestureRecognizer?) {
        self.delegate?.videoPlayerViewDidClose()
    }

    func pausePlayer() {
        isPlayerAutoPaused = true
        if isPlaying() {
            shouldResumePlayer = true
           // contentPlayer?.pause()
            self.playerViewController.player?.pause()
        }

    }

    func resumePlayer() {
        if !isPlaying() && isPlayerAutoPaused && shouldResumePlayer {
            isPlayerAutoPaused = false
            shouldResumePlayer = false
            self.playerViewController.player?.play()
        }
    }

    @IBAction func playPauseTapped(_ sender: Any) {
      if isPlaying() {
            //contentPlayer?.pause()
            self.playerViewController.player?.pause()
           // playheadButton.setImage(UIImage(named: "play"), for: .normal)
            isPlayerPaused = true
            trackEventForAnalytics(action: "playerPause")
        } else {
            //contentPlayer?.play()
            self.playerViewController.player?.play()
           // playheadButton.setImage(UIImage(named: "pause"), for: .normal)
            isPlayerPaused = false
            trackEventForAnalytics(action: "playerResumePlay")
        }
    }

    func string(from interval: TimeInterval) -> String? {
        let ti = Int(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        return String(format: "%ld:%02ld", minutes, seconds)
    }

    func trackEventForAnalytics(action: String) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        if self.articleTitle != nil {
            let params = GAIDictionaryBuilder.createEvent(withCategory: "Video Event", action: action, label: String(format: "%@|%@", self.articleTitle!, self.playURL ?? ""), value: nil).build() as [NSObject: AnyObject]
            tracker.send(params)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }

    @IBAction func captioButtonTapped(_ button: UIButton?) {
        if !isSubtitleDisplayed {
            button?.layer.borderWidth = 1.0
            button?.layer.borderColor = UIColor.white.cgColor
            button?.layer.cornerRadius = 8.0
        } else {
            button?.layer.borderWidth = 0.0
        }

        let asset = contentPlayer?.currentItem?.asset
        let legibleGroup = asset?.mediaSelectionGroup(forMediaCharacteristic: .legible)
        let characteristics = [AVMediaCharacteristic.containsOnlyForcedSubtitles]
        var filteredOptions: [AVMediaSelectionOption]?
        if let options = legibleGroup?.options {
            filteredOptions = AVMediaSelectionGroup.mediaSelectionOptions(from: options, withoutMediaCharacteristics: characteristics)
        }
        if filteredOptions != nil && filteredOptions?.count != nil {
            if !isSubtitleDisplayed {
                // Select the first subtitle track.
                if let legibleGroup = legibleGroup {
                    contentPlayer?.currentItem?.select(filteredOptions?[0], in: legibleGroup)
                }
            } else {
                if let legibleGroup = legibleGroup {
                    contentPlayer?.currentItem?.select(nil, in: legibleGroup)
                }
            }

            isSubtitleDisplayed = !isSubtitleDisplayed

        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return getPreferredStatusBarStyle()
    }

    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        if event.type == IMAAdEventType.LOADED {
            if ((self.pictureInPictureController) != nil) {
                if (!self.pictureInPictureController!.isPictureInPictureActive) {
                    adsManager.start()
                    self.adStartedPlaying = true
                }
            }
            
            
        } else if event.type == IMAAdEventType.CLICKED {
            shouldPersistPlayer = true
        } else if event.type == IMAAdEventType.TAPPED {
            adsManager.resume()
        } else if event.type == IMAAdEventType.STARTED {
            self.addMetaDataForPlayerCurrentItem() // For lock screen
            MBProgressHUD.hide(for: self.view, animated: true)
            trackEventForAnalytics(action: "adStart")
        } else if event.type == IMAAdEventType.ALL_ADS_COMPLETED {
            shouldPersistPlayer = false
            self.adStartedPlaying = false
            trackEventForAnalytics(action: "adComplete")
            destroyAdManager()
        }
    }

    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        if let message = error.message {
            print("AdsManager error: \(message)")
        }
        //self.contentPlayer?.play()
        self.playerViewController.player?.play()
        isAdPlayComplete = true
    }

    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        // The SDK is going to play ads, so pause the content.
       // contentPlayer?.pause()
        self.contentPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        self.isTimeControlsStatusObserverAdded = true
        self.playerViewController.player?.pause()
    }

    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        // The SDK is done playing ads (at least for now), so resume the content.
        self.contentPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        self.isTimeControlsStatusObserverAdded = true
        self.playerViewController.player?.play()
        isAdPlayComplete = true
    }

    func getBottomPadding() -> CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            // window get nil for Demo and Frenzy for iPad
            if window != nil {
                return (window?.safeAreaInsets.bottom)!
            }
            return 0.0
        } else {
            return 0.0
        }
    }

    func getPreferredStatusBarStyle() -> UIStatusBarStyle {
        let statusBarColorWhite: Bool? = AppDefaults.getColorCodeForKey("STATUS_BAR_WHITE") as? Bool
        if statusBarColorWhite != nil {
            if statusBarColorWhite! {
                return .lightContent
            } else {
                return .default
            }
        } else {
            return .default
        }
    }

    func getAdTag() -> String {

        let adTag: NSString? = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "ADS_TAG")) as? NSString
        if adTag != nil {
            return adTag! as String
        }

        return ""
    }

    func getAdURL() -> String {

        let adURL = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "ADS_IMA_URL")) as? String

        if adURL == nil {
            return ""
        }
        return adURL!
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
