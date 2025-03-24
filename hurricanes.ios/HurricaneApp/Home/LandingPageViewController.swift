//
//  LandingPageViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 02/09/16.
//  Copyright © 2016 Graham Media. All rights reserved.
//

import Foundation
import Reachability
import SVGKit
import UIKit
import SDWebImage
import BlueConicClient
import AppTrackingTransparency
import AVKit
import BrazeKit

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

let kLandingPagePatternImage = "tableBackgroundImage.png"
let kHurricaneImageCell = "HurricaneImageCell"
let kTropicsWatchPotentialTableViewCell = "TropicsWatchPotentialTableViewCell"
let kTropicsWatchSatelliteTableViewCell = "TropicsWatchSatelliteTableViewCell"
let kTropicsWatchSeaTempsTableViewCell = "TropicsWatchSeaTempsTableViewCell"
let kradarLayerCell = "RadarLayerCustomCell"
let kSettingsCell = "SettingsCell"
let kAlertBarImage = "alertBarImage.png"
let kLiveStreamBarImage = "liveStreamImage.png"
let kOpenScreenKey = "ab_uri"
let kWXWorksVideoAdCell = "WxVideoCustomTableViewCell"
let kADTableViewCell = "ADTableViewCell"
let kCustomerTableViewHeaderView = "CustomerTableViewHeaderView"
let kNotificationsTableViewCell = "NotificationsTableViewCell"
let kTopSponsorShipCell = "TopSponsorShipTableViewCell"

let kSailthruMessageTableViewCell = "SailthruMessageCellIdentifier"
let kSailthruMessageTableViewCellWithImage = "SailthruMessageCellIdentifierWithImage"
let kSailthruMessageTableViewCellWithDeepLink = "SailthruMessageCellIdentifierWithDeepLink"
let kSailthruMessageTableViewCellAll = "SailthruMessageCellIdentifierAll"
let kSailthruMessageTableViewCellWithImageOnly = "SailthruMessageCellIdentifierWithImageOnly"

/*********************  TROPICAL IMAGES **********************/
let kCategoryRemnants = "Remnants Of"
let kCategoryPostTropicalCyclone = "Post-Tropical Cyclone"
let kCategoryTropicalDepression = "Tropical Depression"
let kCategoryTropicalStorm = "Tropical Storm"
let kCategoryHurricane_1 = "Category 1 Hurricane"
let kCategoryHurricane_2 = "Category 2 Hurricane"
let kCategoryHurricane_3 = "Category 3 Hurricane"
let kCategoryHurricane_4 = "Category 4 Hurricane"
let kCategoryHurricane_5 = "Category 5 Hurricane"
let kImageRemnants = "hurricane_td.png"
let kImagePostTropicalCyclone = "hurricane_td.png"
let kImageTropicalDepression = "hurricane_td.png"
let kImageTropicalStorm = "hurricane_ts.png"
let kNotificationdidUpdateLayer = "NotificationdidUpdateLayer"
let kInitialZoomLevel: CLLocationDegrees = 10.0
/***************************************************************/

var isRequiredBiggerSize = false

enum HomeSections: Int, CaseIterable {
    case Top_Sponsorship = 0
    case Livestream
    case Storms
    case AD_After_Storms
    case InAppNotifications
    case Tropics_Watch
    case AD_After_Tropics_Watch
}

class LandingPageViewController: GAITrackedViewController, NSFetchedResultsControllerDelegate, DataDownloadManagerDelegate, HurricaneImageCellDelegate, AlertBarDelegate, ErrorHandler, UITableViewDelegate, UITableViewDataSource, VideoPlayerViewControllerDelegate, GADBannerViewDelegate,GADAdLoaderDelegate,GADCustomNativeAdLoaderDelegate,ImageViewControllerDelegate {

    var userInfoDictionary: [AnyHashable: Any]?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var statusBarBackgroundView: UIView!
    
    var topSponsorShipView:TopSponsorShipView!
    
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var fetchedTropicsWatchResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var liveStreamViewController: LiveStreamViewController?
    var alertBarViewController: AlertBarViewController!
    var refreshControl: CustomRefreshControl!
    var wxVideoPlayerViewController: WXVideoPlayerViewController!

    var timeWhenDisappered: Date?
    var timeWhenAppeared: Date?
    var notificationOldID: String?
    var isAdRecieved = false
    var isLandscapeRequired = false
    var isStatusBarHidden = false

    static var isRequiredReloadSection = true

    let HurricaneImageCellIdentifier = "HurricaneImageCellIdentifier"
    let TropicsWatchPotentialCellIdentifier = "TropicsWatchPotentialCellIdentifier"
    let TropicsWatchSatelliteCellIdentifier = "TropicsWatchSatelliteCellIdentifier"
    let TropicsWatchSeaTempsCellIdentifier = "TropicsWatchSeaTempsCellIdentifier"
    let SailthruMessageCellIdentifier = "SailthruMessageCellIdentifier"
    let SailthruMessageCellIdentifierWithImage = "SailthruMessageCellIdentifierWithImage"
    let SailthruMessageCellIdentifierWithDeepLink = "SailthruMessageCellIdentifierWithDeepLink"
    let SailthruMessageCellIdentifierAll = "SailthruMessageCellIdentifierAll"
    let SailthruMessageCellIdentifierWithImageOnly = "SailthruMessageCellIdentifierWithImageOnly"
    
    var SettingsCellIdentifier = "SettingsCellIdentifier"
    let WXWorksVideoADCellIdentifier = "WXWorksVideoADCellIdentifier"
    
    let ADCellIdentifier = "ADCellIdentifier"
    let CustomerTableViewHeaderView = "CustomerTableViewHeaderView"
    let TopSponsorShipIdentifier = "TopSponsorShipCellIdentifier"
    
    private var isPlayingPlayerPaused = false

    var selectedLiveStreamObject: [String: Any]!
    var selectedLiveStreamObjectIndex = -1

    var labelVideoTitleView: UIView!
    var videoCellTapped = false
    private let kAdMobAdHeightForBanner = 50
    
    private var adBanner: GAMBannerView!
    private var adBannerMiddle: GAMBannerView!
    private var adBannerLast: GAMBannerView!
    private var adViewArray = [GAMBannerView]()
    private var inAppMessages: NSMutableArray = []
    private var sailthruNotificationTimer = Timer()
    private var topSponsorADLoad = false
    
    private var topSponsorCustomADBanner: GADCustomNativeAd!
    var adLoader: GADAdLoader!
    
    private var imageViewController: ImageViewController?
    private var imageNamePotentialWithPathArray: [AnyObject]?
    private var imageNameSatelliteWithPathArray: [AnyObject]?
    private var imageNameSeaTempsWithPathArray: [AnyObject]?
    private var isStormsDataFound = false
    private var isTropicsDataFound = false
    private var isInAppNotificationsDataFound = false
    private var livestreamIndexPath: IndexPath!
    private var isInLineAdRecieved = false
    private var isInLineTropicsMiddleAdRecieved = false
    private var isInLineTropicsBottomAdRecieved = false
    private var isAppBackground = false
    var isPushReceived = false
    
    private var videoFrame:CGRect!
    private var pinnedFrame:CGRect!
    private var videoPlayerRect:CGRect!
    private var shouldAdjustVideoFrame:Bool! = false
    
    private var loop_gif: String?
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.managedObjectContext = DataManager.sharedInstance.mainObjectContext
        self.refreshControl = CustomRefreshControl()
        self.imageNamePotentialWithPathArray = [AnyObject]()
        self.imageNameSatelliteWithPathArray = [AnyObject]()
        self.imageNameSeaTempsWithPathArray = [AnyObject]()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {

        if !isLandscapeRequired {
            return [.portrait, .portraitUpsideDown]
        } else {

            return .all
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] _ in
            self.createBlueconicEvent()
        }
        
        // Do any additional setup after loading the view from its nib.

        /* Send a screen view to property */
        self.screenName = kLandingPage
        if kNotificationBar {
            self.addAlertBarNotifications()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.displayActiveHurricane), name: NSNotification.Name(rawValue: "DisplayActiveHurricane"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetGoogleMobileBannerAdFlag), name: NSNotification.Name(rawValue: kNotificationGoogleBannerADReset), object: nil)
        
        if self.userInfoDictionary != nil {
            self.view.alpha = 0.4
        }
        self.refreshFetchRequestHAPPData()
        self.setTableProperties()
        
        AppCheckUpdateOnStore.shared.showUpdate(withConfirmation: true)
        
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.labelText = kHUDLabelText
        DataDownloadManager.sharedInstance.downloadAllData()
        
    }
    
    @objc func fetchMessagesNotification(_ notif: Foundation.Notification) {
        self.fetchMessages()
    }
    
    @objc func fetchMessages() {
        
        AppDelegate.braze?.contentCards.requestRefresh { result in
          switch result {
          case .success(let cards):
            print("cards:", cards)
            self.getContentCardsInfo(cards: cards)
              
          case .failure(let error):
            print("error:", error)
          }
        }
        
    }
    
    private func getContentCardsInfo(cards: [BrazeKit.Braze.ContentCard]) {
        
            self.inAppMessages.removeAllObjects()
            
                if cards.count > 0 {
                
                for message in cards {
                    let contyentCard  = message
                    
                    if let image = contyentCard.imageOnly?.image {
                      print("banner - image:", image)
                    }
                    
                    let cardRaw = Braze.ContentCardRaw(contyentCard)
                    print("extras:", cardRaw.extras)
                    print("url:", cardRaw.url ?? "none")
                    
                    // To access card specific fields, you can switch on the `card` enum:
                    switch contyentCard {
                    case .classic(let classic):
                      print("classic - title:", classic.title)
                        self.inAppMessages.add(contyentCard)
                    case .classicImage(let classicImage):
                      print("classicImage - image:", classicImage.title)
                        self.inAppMessages.add(contyentCard)
                    case .imageOnly(let imageOnly):
                      print("banner - image:", imageOnly.image)
                        self.inAppMessages.add(contyentCard)
                    default:
                      break
                    }
                    
                }
                self.tableView.reloadData()
            }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        isStatusBarHidden = false
        self.setNeedsStatusBarAppearanceUpdate()
        self.isLandscapeRequired = false
        
        DataDownloadManager.sharedInstance.errorHandler = self
        DataDownloadManager.sharedInstance.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchMessagesNotification), name: NSNotification.Name(rawValue:kNotificationSailthru), object: nil)
       
        self.setBackButtonItemTitle()
        let adId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kAdMobUnitId) as? String
        
        if adId != nil && self.topSponsorADLoad == false {
            self.loadTopSponsorAd()
        }
        
        self.autoRefreshData()
        
        if self.isPushReceived == true {
            self.refreshData()
            self.isPushReceived = false
        }

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: NSNotification.Name(rawValue: kNotificationWXWorksDataLoad), object: nil)
        
        self.fetchMessages()
        self.sailthruNotificationTimer.invalidate()
        self.sailthruNotificationTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.fetchMessages), userInfo: nil, repeats: true)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BlueconicHelper.createBlueconicEvent(self, forPageView: "Main/LandingPageViewController")

        if self.wxVideoPlayerViewController != nil {
            if (!self.wxVideoPlayerViewController.isPipIsActive) {
                self.resetLivestreamPlayerFrame()
            }
            self.wxVideoPlayerViewController.isPlayerPausedForPushingViewController = false
            
        }

        self.checkLivestreamPlayerIsPaused()

        self.ShowATTPromt()

    }
    
    private func loadTopSponsorAd() {
        
        // Prepare the ad loader and start loading ads.
        let adId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kAdMobUnitId) as? String
          
        adLoader = GADAdLoader(adUnitID: adId!,
                               rootViewController: self,
                               adTypes: [.customNative],
                               options: nil)

        adLoader.delegate = self
        
        let request = GAMRequest()
        
        let myDictOfDict:NSDictionary = ["pos" : "native-radar"]
        
        request.customTargeting = (myDictOfDict as! [String : String])
        adLoader.load(request)
    }
    
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        let template = "11868584"
        return [template]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
      }

      func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADCustomNativeAd) {
        print("Received native ad: \(nativeAd)")
          self.topSponsorCustomADBanner = nativeAd
          self.topSponsorADLoad = true
          self.tableView.reloadData()
      }

    private func loadInlineAd(indexCount : Int) {
        
        let adId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kAdMobUnitId) as? String
        
        if indexCount == 1 {
            self.adBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
            self.adBanner.rootViewController = self
            self.adBanner.delegate = self
            self.adBanner.adUnitID = adId!
            self.adBanner.tag = indexCount
            self.adBanner.load(GAMRequest())
        } else if indexCount == 2 {
            self.adBannerMiddle = GAMBannerView(adSize: GADAdSizeMediumRectangle)
            self.adBannerMiddle.rootViewController = self
            self.adBannerMiddle.delegate = self
            self.adBannerMiddle.adUnitID = adId!
            self.adBannerMiddle.tag = indexCount
            self.adBannerMiddle.load(GAMRequest())
        } else if indexCount == 3 {
            self.adBannerLast = GAMBannerView(adSize: GADAdSizeMediumRectangle)
            self.adBannerLast.rootViewController = self
            self.adBannerLast.delegate = self
            self.adBannerLast.adUnitID = adId!
            self.adBannerLast.tag = indexCount
            self.adBannerLast.load(GAMRequest())
        }
        
        
    }
    
    private func checkLivestreamPlayerIsPaused() {
        if self.isPlayingPlayerPaused == true {
            if self.wxVideoPlayerViewController != nil {

                if self.wxVideoPlayerViewController.adStartedPlaying == true && self.wxVideoPlayerViewController.isPlayerPausedForPushingViewController == false {
                    // check ad is paused
                    self.wxVideoPlayerViewController.adsManager?.resume()
                } else if self.wxVideoPlayerViewController.contentPlayer?.timeControlStatus == .paused && self.wxVideoPlayerViewController.isPlayerPausedForPushingViewController == false {
                    // check video player is paused
                    self.wxVideoPlayerViewController.contentPlayer?.play()
                    self.isPlayingPlayerPaused = false
                }
            }
        }
    }

    @objc func reloadTableViewData(_ notificationObject: Foundation.Notification) {

        self.checkLivestreamPlayerIsPaused()
        self.tableView.reloadData()
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override var shouldAutorotate: Bool {
        return false
    }

    func setNavigationBarImage() {
        let headerImageView = UIImageView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarHeight, width: UIScreen.main.bounds.width, height: navigationBarHeight))
        view.addSubview(headerImageView)

        if Float(UIScreen.main.bounds.size.width) == kIphone6Width {
            headerImageView.image = UIImage(named: kNavigationBarImageForIphone6)!
        } else {
            headerImageView.image = UIImage(named: kNavigationBarImage)!
        }

        var frame = self.tableView.frame
        frame.origin.y = UIApplication.shared.statusBarHeight
        frame.size.height = frame.size.height - frame.origin.y
        self.tableView.frame = frame
    }

    @objc func pushNotificationReceived(_ notificationObject: Foundation.Notification) {
        self.userInfoDictionary = (notificationObject as NSNotification).userInfo
        self.downloadAllData()
        self.fetchMessages()
    }

    @objc func displayActiveHurricane(_ notificationObject: Foundation.Notification) {
        if (notificationObject as NSNotification).userInfo != nil {
            let idx = ((notificationObject as NSNotification).userInfo!["stormId"] as! String)
            let entity = DataDownloadManager.sharedInstance.getEntityForId(idx)
            if entity == kEntityStormCenter {
                self.setPushGANTrackEventWithLabel(kStormCenter)
                self.pushStormCenterForId(idx)
            } else {
                self.pushToInformationNotAvailable()
            }
        }
    }
    
    func setTableProperties() {
        self.view.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
        self.statusBarBackgroundView.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
        var statusBarBGFrame = self.statusBarBackgroundView.frame
        statusBarBGFrame.size.height = UIApplication.shared.statusBarFrame.height
        self.statusBarBackgroundView.frame = statusBarBGFrame
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.separatorColor = UIColor.clear
        self.tableView.tableHeaderView = nil
        self.tableView.tableFooterView = nil
        
        self.tableView.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
        self.tableView.register(UINib(nibName: kHurricaneImageCell, bundle: nil), forCellReuseIdentifier: HurricaneImageCellIdentifier)
        
        self.tableView.register(UINib(nibName: kTropicsWatchPotentialTableViewCell, bundle: nil), forCellReuseIdentifier: TropicsWatchPotentialCellIdentifier)
        self.tableView.register(UINib(nibName: kTropicsWatchSatelliteTableViewCell, bundle: nil), forCellReuseIdentifier: TropicsWatchSatelliteCellIdentifier)
        self.tableView.register(UINib(nibName: kTropicsWatchSeaTempsTableViewCell, bundle: nil), forCellReuseIdentifier: TropicsWatchSeaTempsCellIdentifier)
        
        self.tableView.register(UINib(nibName: kSailthruMessageTableViewCell, bundle: nil), forCellReuseIdentifier: SailthruMessageCellIdentifier)
        self.tableView.register(UINib(nibName: kSailthruMessageTableViewCellWithImage, bundle: nil), forCellReuseIdentifier: SailthruMessageCellIdentifierWithImage)
        self.tableView.register(UINib(nibName: kSailthruMessageTableViewCellWithDeepLink, bundle: nil), forCellReuseIdentifier: SailthruMessageCellIdentifierWithDeepLink)
        self.tableView.register(UINib(nibName: kSailthruMessageTableViewCellAll, bundle: nil), forCellReuseIdentifier: SailthruMessageCellIdentifierAll)
        self.tableView.register(UINib(nibName: kSailthruMessageTableViewCellWithImageOnly, bundle: nil), forCellReuseIdentifier: SailthruMessageCellIdentifierWithImageOnly)
        
        self.tableView.register(UINib(nibName: kSettingsCell, bundle: nil), forCellReuseIdentifier: SettingsCellIdentifier)
        self.tableView.register(UINib(nibName: kWXWorksVideoAdCell, bundle: nil), forCellReuseIdentifier: WXWorksVideoADCellIdentifier)
        self.tableView.register(UINib(nibName: kADTableViewCell, bundle: nil), forCellReuseIdentifier: ADCellIdentifier)
        self.tableView.register(UINib(nibName: kTopSponsorShipCell, bundle: nil), forCellReuseIdentifier: TopSponsorShipIdentifier)
        
        self.tableView.register(UINib(nibName: kCustomerTableViewHeaderView, bundle: nil),forHeaderFooterViewReuseIdentifier: CustomerTableViewHeaderView)
                                
        self.tableView.addSubview(self.refreshControl)
        self.refreshControl.addTarget(self, action: #selector(self.refreshControlTableWithData), for: .valueChanged)
        
        self.tableView!.estimatedRowHeight = 100.0
    }

    func didSuccess(toSaveData isSuccess: Bool) {
        self.view.alpha = 1.0
        MBProgressHUD.hide(for: self.view, animated: true)
        if !isSuccess {
            self.refreshControl.endRefreshing()
            return
        }
        self.refreshControl.endRefreshing()
        self.pushOnNotification()
        self.showLiveStreamBar()
        
        self.refreshFetchRequestHAPPData()
        self.tableView.reloadData()
    }
    
    private func refreshFetchRequestHAPPData() {
        do {
            try self.getFetchedResultsController().performFetch()
            try self.getFetchedTropicsResultsController().performFetch()
        } catch let error {
            print("Unresolved error in fetching data: \(error.localizedDescription)")
        }
    }

    func pushOnNotification() {
        if self.userInfoDictionary != nil {
            guard self.navigationController?.popToRootViewController(animated: false) != nil
            else {
                print("No Navigation Controller")
                self.navigationController?.navigationBar.alpha = 1.0
                
                if let screenName = self.userInfoDictionary![kOpenScreenKey] as? String {
                    self.pushScreenForId(screenName)
                }
                
                self.userInfoDictionary = nil
                return
            }

            self.navigationController?.navigationBar.alpha = 1.0
            //self.pushScreenForId((self.userInfoDictionary![kOpenScreenKey] as! String))
            if let screenName = self.userInfoDictionary![kOpenScreenKey] as? String {
                self.pushScreenForId(screenName)
            }
        }
        self.userInfoDictionary = nil
    }

    func pushToInformationNotAvailable() {
        let infoNotAvailableViewController = InfoNotAvailableViewController(nibName: "InfoNotAvailableViewController", bundle: nil)
        self.navigationController?.pushViewController(infoNotAvailableViewController, animated: true)
    }

    func pushScreenForId(_ idx: String) {
        let entity = DataDownloadManager.sharedInstance.getEntityForId(idx)
        if entity == kEntityNotifications {
            self.setPushGANTrackEventWithLabel(kNotification)
            self.pushNotificationsForId(idx)
        } else if entity == kEntityStormCenter {
            self.setPushGANTrackEventWithLabel(kStormCenter)
            self.pushStormCenterForId(idx)
        } else {
            self.pushToInformationNotAvailable()
        }

    }

    func setPushGANTrackEventWithLabel(_ label: String) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        let params = GAIDictionaryBuilder.createEvent(withCategory: kPushAlert, action: kOpened, label: nil, value: nil).build()as [NSObject: AnyObject]
        tracker.send(params)
    }

    func pushNotificationsForId(_ idx: String) {
        let notification = DataDownloadManager.sharedInstance.getDataForEntity(kEntityNotifications, id: idx)?.last as? Notification
        
        if notification != nil {
            if self.alertBarViewController == nil {
                self.alertBarViewController = AlertBarViewController(nibName: "AlertBarViewController", bundle: nil)
                self.addChild(alertBarViewController)
                self.alertBarViewController.delegate = self
            }
            self.alertBarViewController.notification = notification
            self.alertBarViewController.pushOnNotification()
        }
        
    }

    func pushStormCenterForId(_ stormId: String) {
        let stormCenterViewController = StormCenterViewController(nibName: "StormCenterViewController", bundle: nil)
        let stormCenterArray = DataDownloadManager.sharedInstance.getStormDataforID(stormId)
        if stormCenterArray != nil {
            for stormCenter: Any in stormCenterArray! {
                let indexBasedSort = NSSortDescriptor(key: "index", ascending: true)
                let stormDetail = (stormCenter as! StormCenter).stormCenterDetail
                if stormDetail != nil {
                    stormCenterViewController.stormCenterDetailArray = (stormDetail!.allObjects as NSArray).sortedArray(using: [indexBasedSort]) as [AnyObject]
                }
            }
        }
        if stormCenterViewController.stormCenterDetailArray?.count > 0 {
            self.navigationController?.pushViewController(stormCenterViewController, animated: true)
        } else {
            let alertController = UIAlertController(title: kErrorTitle_NoData, message: "No Storm Exists", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: kOk, style: UIAlertAction.Style.default) { (_: UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @objc func refreshControlTableWithData() {
        self.downloadAllData()
        let adId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kAdMobUnitId) as? String
        if adId != nil && self.topSponsorADLoad == false {
            self.loadTopSponsorAd()
        }
        
        if adId != nil && !self.isInLineAdRecieved {
            self.loadInlineAd(indexCount: 1)
        }
    }

    func downloadAllData() {
        //reset ADS
        self.isInLineAdRecieved = false
        self.isInLineTropicsMiddleAdRecieved = false
        self.isInLineTropicsBottomAdRecieved = false
        
        self.adViewArray.removeAll()
        
        let notification = DataDownloadManager.sharedInstance.getNotificationsData()?.last
        if let notif = notification as? Notification {
            self.notificationOldID = notif.idx
        }
        
        DataDownloadManager.sharedInstance.delegate = self
        DataDownloadManager.sharedInstance.downloadAllData()
    }

    func showLiveStreamBar() {
        if !kLiveStreamBar {
            return
        }
        let liveStreamArray = DataDownloadManager.sharedInstance.getLiveStreamData()
        if liveStreamArray == nil || liveStreamArray!.count == 0 {
            self.liveStreamViewController?.view.isHidden = true
            self.liveStreamViewController?.view.removeFromSuperview()
            self.liveStreamViewController = nil
            return
        }
        if liveStreamViewController == nil {
            self.liveStreamViewController = LiveStreamViewController(nibName: "LiveStreamViewController", bundle: nil)
            self.addChild(self.liveStreamViewController!)
            if isAdRecieved {
                self.liveStreamViewController!.setLiveStreamFrameAfterDisplayingAd()
            }
            self.view.addSubview(self.liveStreamViewController!.view)
        }
        self.liveStreamViewController!.liveStream = liveStreamArray!.last as? LiveStream
    }

    func addAlertBarNotifications() {
//        NotificationCenter.default.addObserver(self, selector: #selector(self.addAlertBar), name: NSNotification.Name(rawValue: kNotificationTimeStart), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.removeAlertBar), name: NSNotification.Name(rawValue: kNotificationTimeStop), object: nil)
    }

    @objc func addAlertBar() {
        let defaultNotificationKey = UserDefaults.standard.object(forKey: kNotificationKey) as? String
        let notification = DataDownloadManager.sharedInstance.getNotificationsData()?.last
        if self.notificationOldID == nil {
            self.notificationOldID = (notification as! Notification).idx
        }
        if defaultNotificationKey == (notification as! Notification).idx {
            return
        }
        if alertBarViewController == nil {
            var frame = self.alertView.frame
            frame.origin.y = UIApplication.shared.statusBarFrame.height + navigationBarHeight
            self.alertView.frame = frame

            self.alertBarViewController = AlertBarViewController(nibName: "AlertBarViewController", bundle: nil)
            self.addChild(alertBarViewController)
            self.alertView.addSubview(self.alertBarViewController.view)
            self.alertView.isHidden = false
            UIView.animate(withDuration: kNotificationBarAnimation, delay: 0, options: .transitionFlipFromTop, animations: { [weak self] () -> Void in
                var origin = CGPoint.zero
                    if let strongSelf = self {
                        if #available(iOS 11.0, *) {
                            origin = CGPoint(x: 0.0, y: (strongSelf.alertView.frame.origin.y + strongSelf.alertView.frame.size.height) - 5)
                        } else {
                            origin = CGPoint(x: 0.0, y: strongSelf.alertView.frame.origin.y)
                        }
                        var frame = strongSelf.tableView.frame
                        frame.origin = origin
                        frame.size.height = (frame.size.height - (frame.origin.y + AppDefaults.getBottomPadding())) + UIApplication.shared.statusBarHeight
                        strongSelf.tableView.frame = frame
                    }
                }, completion: {(_: Bool) -> Void in
            })
        }
        self.alertBarViewController.delegate = self
        self.alertBarViewController.notification = notification as? Notification
        if let notif = notification as? Notification {
            self.notificationOldID = notif.idx
        }
    }

    func alertShouldStopDisplay() {
        self.removeAlertBar()
    }

    @objc func removeAlertBar() {
        if alertBarViewController != nil {
            print("stopShowingNotification!")
            self.alertBarViewController.view.isHidden = true
            self.alertBarViewController.view.removeFromSuperview()
            self.alertBarViewController = nil
            UIView.animate(withDuration: kNotificationBarAnimation, delay: 0, options: .transitionFlipFromTop, animations: { [weak self] () -> Void in
                    if let strongSelf = self {
                        var frame = strongSelf.tableView.frame
                        frame.size.height = (frame.size.height + (frame.origin.y + AppDefaults.getBottomPadding())) - UIApplication.shared.statusBarHeight
                        frame.origin = CGPoint(x: 0, y: UIApplication.shared.statusBarHeight)
                        strongSelf.tableView.frame = frame
                    }
                }, completion: {(_: Bool) -> Void in
            })

            self.alertView.isHidden = false
        }
    }

    func setBackButtonItemTitle() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: kBackButtonTitle, style: .plain, target: nil, action: nil)
    }

    @objc func reachabilityChanged(_ notif: Foundation.Notification) {
        let curReach = (notif.object! as! Reachability)
        let netStatus = curReach.currentReachabilityStatus()
        if netStatus != NetworkStatus.NotReachable {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud?.labelText = kHUDLabelText
            hud?.labelFont = kHUDLabelFont
            self.downloadAllData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear = \(Date())")
        self.timeWhenDisappered = Date()
    
        self.checkVideoPlayerIsPlaying()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotificationWXWorksDataLoad), object: self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotificationSailthru), object: self)
        
        self.sailthruNotificationTimer.invalidate()
        
        super.viewWillDisappear(animated)
        
        self.takeSnapShotOfView()
    }

    func autoRefreshData() {
        self.timeWhenAppeared = Date()
        if self.timeWhenDisappered != nil {
            let timeInterval = self.timeWhenAppeared!.timeIntervalSince(self.timeWhenDisappered!)
            if timeInterval > Double(kAutoRefreshTimeInterval) {
                self.refreshData()
            } else if self.isAppBackground == true {
                self.refreshData()
                self.isAppBackground = false
            }
        }
    }

    func refreshData() {
        print("Calling Refresh data")
        self.downloadAllData()
        self.refreshControl.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.size.height), animated: true)
    }

    func didSuccessToReceiveAd() {
    //    self.isAdRecieved = true
       // self.liveStreamViewController?.setLiveStreamFrameAfterDisplayingAd()
//        var frame = self.tableView.frame
//        frame.size.height = frame.size.height - CGFloat(kAdMobAdHeight) - CGFloat(AppDefaults.getBottomPadding())
//        self.tableView.frame = frame
//
//        if self.wxVideoPlayerViewController != nil {
//            if self.wxVideoPlayerViewController.isVideoFullscreen == true {
////                self.adMobViewController.hideBannerAD()
//            }
//        }

    }

    func didFailToReceiveAd() {
        self.isAdRecieved = false
    }

    func didAdViewPresentScreen() {
        self.isLandscapeRequired = true
    }

    func didAdViewDismissScreen() {
        self.isLandscapeRequired = false
    }

    func didBannerViewDidRecordClick() {
        self.checkVideoPlayerIsPlaying()
    }

    func hurricaneImageCellDidTapped() {
        let stormCenterViewController = StormCenterViewController(nibName: "StormCenterViewController", bundle: nil)
        self.navigationController?.pushViewController(stormCenterViewController, animated: true)
    }

    private func checkVideoPlayerIsPlaying() {
        if self.wxVideoPlayerViewController != nil {
            
            if (self.wxVideoPlayerViewController.isPipIsActive) {
                return
            }
            
            if self.wxVideoPlayerViewController.adStartedPlaying == true {
                // check ad is playing
                self.wxVideoPlayerViewController.adsManager?.pause()
                self.isPlayingPlayerPaused = true
                self.wxVideoPlayerViewController.isPlayerPausedForPushingViewController = true
            } else if self.wxVideoPlayerViewController.contentPlayer?.timeControlStatus == .playing {
                // video player is playing
                self.wxVideoPlayerViewController.contentPlayer?.pause()
                self.isPlayingPlayerPaused = true
                self.wxVideoPlayerViewController.isPlayerPausedForPushingViewController = true
            }
        }
    }

    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == HomeSections.Storms.rawValue {
            // storms
            let noOfObjects = fetchedResultsController.fetchedObjects?.count
        
            if noOfObjects != nil {
                if noOfObjects > 0 {
                    return 50
                } else {
                    return CGFloat.leastNormalMagnitude
                }
            } else {
                return CGFloat.leastNormalMagnitude
            }
            
        } else if section == HomeSections.Tropics_Watch.rawValue {
            // tropics
            
            let noOfObjects = self.fetchedTropicsWatchResultsController.sections?[0].numberOfObjects
            
            if noOfObjects != nil {
                if noOfObjects > 0 {
                    return 50
                } else {
                    return CGFloat.leastNormalMagnitude
                }
            } else {
                return CGFloat.leastNormalMagnitude
            }
        } else {
            return CGFloat.leastNormalMagnitude
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == HomeSections.Storms.rawValue {
            
            let noOfObjects = fetchedResultsController.fetchedObjects?.count
        
            if noOfObjects != nil {
                if noOfObjects > 0 {
                    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kCustomerTableViewHeaderView) as! CustomerTableViewHeaderView
                    headerView.contentView.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
                    headerView.labelTitle.font = UIFont(name:kHurricaneFont_SemiBold, size: (IS_IPAD ? 29:23))
                    headerView.labelTitle.text = "Currently"
                    
                    return headerView
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else if section == HomeSections.Tropics_Watch.rawValue {
            
            let noOfObjects = self.fetchedTropicsWatchResultsController.sections?[0].numberOfObjects
            
            if noOfObjects != nil {
               
                if noOfObjects > 0 {
                    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kCustomerTableViewHeaderView) as! CustomerTableViewHeaderView
                    headerView.contentView.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
                    headerView.labelTitle.font = UIFont(name:kHurricaneFont_SemiBold, size: (IS_IPAD ? 29:23))
                    headerView.labelTitle.text = "Tropics Watch"
                    
                    return headerView
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == HomeSections.Top_Sponsorship.rawValue {
            // top sponsorship
            return 60
            
        } else if indexPath.section == HomeSections.InAppNotifications.rawValue {
            // in app notifications
            return UITableView.automaticDimension
            
        } else if indexPath.section == HomeSections.Livestream.rawValue {
            // live stream
            if DataDownloadManager.sharedInstance.liveStreamArray != nil {
                
                if (self.wxVideoPlayerViewController != nil) {
                    if (self.wxVideoPlayerViewController.isPipIsActive) {
                        return 0
                    } else {
                        return UITableView.automaticDimension
                    }
                } else {
                    return UITableView.automaticDimension
                }
                
            } else {
                return 0
            }
            
        } else if indexPath.section == HomeSections.AD_After_Storms.rawValue {
            // after storms AD display
            if self.adViewArray.count > 0 && self.isStormsDataFound == true {
                return 293
            } else {
                return 0
            }
            
        } else if indexPath.section == HomeSections.Storms.rawValue {
            // storm alerts
            return UITableView.automaticDimension
            
        } else if indexPath.section == HomeSections.Tropics_Watch.rawValue {
            // tropics watch
            if self.isInLineTropicsMiddleAdRecieved == true && indexPath.row == 1 && self.adViewArray.count > 1 {
                // For Middle AD
                return 293
            } else {
                return UITableView.automaticDimension
            }
            
        } else if indexPath.section == HomeSections.AD_After_Tropics_Watch.rawValue {
            // after tropics watch ad display
            if self.adViewArray.count > 2 && self.isInLineTropicsBottomAdRecieved == true {
                return 293
            } else {
                return 0
            }
            
        } else {
            return UITableView.automaticDimension
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == HomeSections.Top_Sponsorship.rawValue {
            // Top_Sponsorship
            if self.topSponsorADLoad == true {
                return 1
            } else {
                return 0
            }
        } else if section == HomeSections.InAppNotifications.rawValue {
            // In app notifications
            if self.inAppMessages.count > 0 {
                self.isInAppNotificationsDataFound = true
            }
            return self.inAppMessages.count
        } else if section == HomeSections.Livestream.rawValue {
            // live stream
            if DataDownloadManager.sharedInstance.liveStreamArray != nil {
                   if DataDownloadManager.sharedInstance.liveStreamArray!.count > 0 {
                       return DataDownloadManager.sharedInstance.liveStreamArray!.count
                   } else {
                       return 0
                   }
    
            } else {
                   return 0
            }
        } else if section == HomeSections.Storms.rawValue {
            // storm alerts
            
            let noOfObjects = fetchedResultsController.fetchedObjects?.count
        
            if noOfObjects != nil {
                if noOfObjects > 0 {
                    self.isStormsDataFound = true
                    let adId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kAdMobUnitId) as? String
                    
                    if adId != nil && !self.isInLineAdRecieved {
                        self.loadInlineAd(indexCount: 1)
                    }
                  
                } else {
                    self.isStormsDataFound = false
                }
                return noOfObjects!
            } else {
                self.isStormsDataFound = false
            }
        } else if section == HomeSections.AD_After_Storms.rawValue {

            if self.adViewArray.count > 0 && self.isStormsDataFound == true {
                    return 1
            } else {
                return 0
            }
        } else if section == HomeSections.Tropics_Watch.rawValue {
            
            let noOfObjects = fetchedTropicsWatchResultsController.fetchedObjects?.count
            self.isTropicsDataFound = false
            
            if noOfObjects != nil {
                if noOfObjects > 0 {
                   
                    let adId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kAdMobUnitId) as? String
                    
                    if adId != nil && !self.isInLineAdRecieved {
                        self.loadInlineAd(indexCount: 1)
                    }
                    
                    if noOfObjects! >= 2 && !isInLineTropicsMiddleAdRecieved {
                        // For middle AD
                        self.loadInlineAd(indexCount: 2)
                        return noOfObjects!
                    } else if self.isInLineTropicsMiddleAdRecieved == true && self.adViewArray.count > 1 {
                        return noOfObjects! + 1
                    } else {
                        return noOfObjects!
                    }
                    
                } else {
                 
                    return 0
                }
            } else {
                return 0
            }
            
            
        } else if section == HomeSections.AD_After_Tropics_Watch.rawValue {
            // for last AD
           // if self.adViewArray.count > 0 && self.isStormsDataFound == false {
            if self.adViewArray.count > 2 && self.isInLineTropicsBottomAdRecieved == true {
                return 1
            } else {
                return 0
            }
           // return 0
            
        } else {
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == HomeSections.Top_Sponsorship.rawValue {
           // Top Sponsorship
            let topSponsorShipCell = (tableView.dequeueReusableCell(withIdentifier: TopSponsorShipIdentifier)! as! TopSponsorShipTableViewCell)
            if (self.topSponsorCustomADBanner != nil) {
                
                let image = self.topSponsorCustomADBanner.image(forKey: "Image")!.image
                
                if image != nil {
                    let resizedImage = self.resizeImage(image: image!, targetSize: CGSize(width: topSponsorShipCell.sponsorAD.frame.size.width, height: topSponsorShipCell.sponsorAD.frame.size.height))
                    let imagV = UIImageView(image: resizedImage)
                    imagV.center = CGPoint(x:imagV.center.x, y: topSponsorShipCell.sponsorAD.center.y)
                    topSponsorShipCell.sponsorAD.addSubview(imagV)
                    topSponsorShipCell.sponsorAD.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performClickOnAdImage)))
                }
            }

           return topSponsorShipCell
       } else if indexPath.section == HomeSections.InAppNotifications.rawValue {
           // In App Notification
           let message = self.inAppMessages[indexPath.row] as! BrazeKit.Braze.ContentCard
           
           let imageUrl = message.imageURL
           
           var isImageavailable = false
           
           if imageUrl != nil {
               isImageavailable = true
           }
           
           let cardRaw = Braze.ContentCardRaw(message)
         
           let deepLinkURL = cardRaw.url
         
           var isDeepLinkavailable = false
           
           if deepLinkURL != nil {
               isDeepLinkavailable = true
           }
           
           var sailthruMessageCell:SailthruMessageCell!
           
           var isBannerType = false
           
           switch message {
               case .imageOnly(let imageOnly):
                   print("banner - image:", imageOnly.image)
                   isBannerType = true
               default:
                 break
           }
           
           if isBannerType == true {
               sailthruMessageCell = (tableView.dequeueReusableCell(withIdentifier: SailthruMessageCellIdentifierWithImageOnly)! as! SailthruMessageCell)
           } else if isImageavailable == true && isDeepLinkavailable == true {
               sailthruMessageCell = (tableView.dequeueReusableCell(withIdentifier: SailthruMessageCellIdentifierAll)! as! SailthruMessageCell)
           } else if isImageavailable == false && isDeepLinkavailable == true {
               sailthruMessageCell = (tableView.dequeueReusableCell(withIdentifier: SailthruMessageCellIdentifierWithDeepLink)! as! SailthruMessageCell)
           } else if isImageavailable == true && isDeepLinkavailable == false {
               sailthruMessageCell = (tableView.dequeueReusableCell(withIdentifier: SailthruMessageCellIdentifierWithImage)! as! SailthruMessageCell)
           } else {
               sailthruMessageCell = (tableView.dequeueReusableCell(withIdentifier: SailthruMessageCellIdentifier)! as! SailthruMessageCell)
           }
    
           self.configureNotificationCell(sailthruMessageCell, atIndexPath: indexPath,message: message)
           return sailthruMessageCell
           
       } else if indexPath.section == HomeSections.Livestream.rawValue {
           // live streaming
           let liveStreamVideoCell = (tableView.dequeueReusableCell(withIdentifier: WXWorksVideoADCellIdentifier)! as! WxVideoCustomTableViewCell)
           liveStreamVideoCell.delegate = self
          
          if DataDownloadManager.sharedInstance.liveStreamArray != nil {
              if DataDownloadManager.sharedInstance.liveStreamArray!.count > 0 {
                  let liveStreamObject = DataDownloadManager.sharedInstance.liveStreamArray[indexPath.row]

                  let thumbUrlStr = liveStreamObject["image"]

                  let thumbnailURL = URL(string: thumbUrlStr! as! String)

                  self.downloadImage(cell: liveStreamVideoCell, url: thumbnailURL!)

                  let tapGesture = UITapGestureRecognizer()
                  tapGesture.numberOfTapsRequired = 1
                  tapGesture.addTarget(self, action: #selector(livestreamVideoCellButtonTapped(_:)))
                  
                  let height = CGFloat(kiPadRatioForVideoDisplay*UIScreen.main.bounds.width)
                  liveStreamVideoCell.videoImageView.heightAnchor.constraint(equalToConstant: height ).isActive = true
                  liveStreamVideoCell.videoImageView.addGestureRecognizer(tapGesture)
                  
                  let titleStr = liveStreamObject["title"] as? String
                  liveStreamVideoCell.titleLabel.text = titleStr
              } else {
                  return liveStreamVideoCell
              }
              
          } else {
              return liveStreamVideoCell
          }
           

           return liveStreamVideoCell
       } else if indexPath.section == HomeSections.AD_After_Storms.rawValue {
            // AD
            let adCell = (tableView.dequeueReusableCell(withIdentifier: ADCellIdentifier)! as! ADTableViewCell)
            
           if self.adViewArray.count > 0 {
               let adView = self.adViewArray[0]
               var adFrame = adView.frame
               adFrame.origin.x = (UIScreen.main.bounds.size.width/2) - (adFrame.size.width/2)
               adView.frame = adFrame
               adCell.myBackgroundView.addSubview(adView)
           }
            
            
//            if self.isInAppNotificationsDataFound == false {
//                adCell.seperatorLine.isHidden = true
//            } else {
                adCell.seperatorLine.isHidden = false
           // }

            return adCell
        } else if indexPath.section == HomeSections.Tropics_Watch.rawValue {
            // tropics watch
            
            if self.isInLineTropicsMiddleAdRecieved == true && indexPath.row == 1 && self.adViewArray.count > 1 {
                // For AD after Potential section
                let adCell = (tableView.dequeueReusableCell(withIdentifier: ADCellIdentifier)! as! ADTableViewCell)
                
                let adView = self.adViewArray[1]
                var adFrame = adView.frame
                adFrame.origin.x = (UIScreen.main.bounds.size.width/2) - (adFrame.size.width/2)
                adView.frame = adFrame
                adCell.myBackgroundView.addSubview(adView)
                
                adCell.seperatorLine.isHidden = false

                return adCell
            } else {
                
                var tropicsCell:TropicsWatchTableViewCell!
                
                var indexForSattelite = 1
                
                if self.isInLineTropicsMiddleAdRecieved == true && self.adViewArray.count > 1 {
                    indexForSattelite = 2
                }
                
                if indexPath.row == 0 {
                    tropicsCell = (tableView.dequeueReusableCell(withIdentifier: TropicsWatchPotentialCellIdentifier)! as! TropicsWatchTableViewCell)
                    tropicsCell.tag = 0
                } else if indexPath.row == indexForSattelite {
                    tropicsCell = (tableView.dequeueReusableCell(withIdentifier: TropicsWatchSatelliteCellIdentifier)! as! TropicsWatchTableViewCell)
                    tropicsCell.tag = 1
                } else if indexPath.row == (indexForSattelite+1) {
                    tropicsCell = (tableView.dequeueReusableCell(withIdentifier: TropicsWatchSeaTempsCellIdentifier)! as! TropicsWatchTableViewCell)
                    tropicsCell.tag = 2
                } else {
                    // to fix crash
                    tropicsCell = (tableView.dequeueReusableCell(withIdentifier: TropicsWatchPotentialCellIdentifier)! as! TropicsWatchTableViewCell)
                    tropicsCell.tag = 0
                }
                
                if tropicsCell != nil {
                    tropicsCell.delegate = self
                    self.configureTropicsWatchCell(tropicsCell, atIndexPath: indexPath,isFetchUpdate: false)
                    
                }
                
                return tropicsCell
                
            }
           
            
        } else if indexPath.section == HomeSections.Storms.rawValue {
            // hurricane storm
            let hurricaneImageCell = (tableView.dequeueReusableCell(withIdentifier: HurricaneImageCellIdentifier)! as! HurricaneImageCell)
            hurricaneImageCell.delegate = self
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(cellButtonTapped(_:)))
            hurricaneImageCell.cellButton.addGestureRecognizer(tapGesture)
            self.configureCell(hurricaneImageCell, atIndexPath: indexPath)
            
            return hurricaneImageCell
            
        } else if indexPath.section == HomeSections.AD_After_Tropics_Watch.rawValue {
            // AD
            let adCell = (tableView.dequeueReusableCell(withIdentifier: ADCellIdentifier)! as! ADTableViewCell)
            
            if self.isInLineTropicsBottomAdRecieved == true && self.adViewArray.count > 2 {
                let adView = self.adViewArray[2]
                var adFrame = adView.frame
                adFrame.origin.x = (UIScreen.main.bounds.size.width/2) - (adFrame.size.width/2)
                adView.frame = adFrame
                adCell.myBackgroundView.addSubview(adView)
                
                adCell.seperatorLine.isHidden = true
            }
            

            return adCell
        } else {
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func downloadImage(cell: WxVideoCustomTableViewCell, url: URL) {
        let request = NSMutableURLRequest(url: url)
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        let requestURL = url

        if !requestURL.absoluteString.isEmpty {
            let imageRequest: URLRequest = URLRequest(url: requestURL)
            let task = URLSession.shared.dataTask(with: imageRequest) {
                data, _, error in
                if error == nil {
                    DispatchQueue.main.async {
                        cell.videoImageView.image = UIImage(data: data!)
                    }
                }
            }
            task.resume()
        }
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func zoomRequiredOnCell(_ cell: TropicsWatchTableViewCell) {
        
        self.checkVideoPlayerIsPlaying()
        
        var screenFrame: CGRect = UIScreen.main.bounds
        screenFrame.origin.y = 0.0
        self.view.frame = screenFrame
        if self.navigationController != nil {
            self.navigationController!.isNavigationBarHidden = true
        }

        self.imageViewController = ImageViewController(nibName: "ImageViewController", bundle: nil)
        self.imageViewController!.delegate = self
        let relativeY: CGFloat = cell.frame.origin.y - self.tableView.contentOffset.y
        self.imageViewController!.relativeY = relativeY
        
        if cell.tag == 0 {
            self.imageViewController!.animationImageViewArray = self.imageNamePotentialWithPathArray as NSArray?
            self.imageViewController!.loop_gif = nil
        } else if cell.tag == 1 {
            self.imageViewController!.animationImageViewArray = self.imageNameSatelliteWithPathArray as NSArray?
            self.imageViewController!.loop_gif = self.loop_gif
        } else if cell.tag == 2 {
            self.imageViewController!.animationImageViewArray = self.imageNameSeaTempsWithPathArray as NSArray?
            self.imageViewController!.loop_gif = nil
        }
        
        self.imageViewController!.selectedImage = cell.stormImageView
        self.imageViewController!.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(self.imageViewController!, animated: false)

    }
    
    func configureCell(_ cell: HurricaneImageCell, atIndexPath indexPath: IndexPath) {
        if fetchedResultsController.fetchedObjects?.count == 0 {
            return
        }
        print(indexPath.section)
        var correctIndexPath = indexPath
        correctIndexPath.section = 0 // HAPP-623
        let stormCenter = fetchedResultsController.object(at: correctIndexPath) as! StormCenter
        cell.nameLabel.text = stormCenter.stormName
        cell.subLabel.text = stormCenter.subhead
        cell.nameLabel.contentMode = .bottom
        cell.subLabel.contentMode = .top
        
        cell.categoryLabel.isHidden = true
        let subviews = cell.leftIconImageView.subviews
        for subView: AnyObject in subviews {
            subView.removeFromSuperview()
        }
        if stormCenter.type?.caseInsensitiveCompare(kCategoryRemnants) == ComparisonResult.orderedSame {
            cell.leftIconImageView.image = UIImage(named: kImageRemnants)!
        } else if stormCenter.type?.caseInsensitiveCompare(kCategoryPostTropicalCyclone) == ComparisonResult.orderedSame {
            cell.leftIconImageView.image = UIImage(named: kImagePostTropicalCyclone)!
        } else if stormCenter.type?.caseInsensitiveCompare(kCategoryTropicalDepression) == ComparisonResult.orderedSame {
            cell.leftIconImageView.image = UIImage(named: kImageTropicalDepression)!
        } else if stormCenter.type?.caseInsensitiveCompare(kCategoryTropicalStorm) == ComparisonResult.orderedSame {
            cell.leftIconImageView.image = UIImage(named: kImageTropicalStorm)!
        } else {
            cell.leftIconImageView.image = nil
            let customImage = SVGKImage(named: kHurricaneBackgroundImage)!
            let hurricaneBGImageView = SVGKFastImageView.init(svgkImage: customImage)
            hurricaneBGImageView?.frame = CGRect(x: 10, y: 10, width: cell.leftIconImageView.frame.size.width - 20, height: cell.leftIconImageView.frame.size.height - 20)
            cell.leftIconImageView.addSubview(hurricaneBGImageView!)
            if stormCenter.type?.caseInsensitiveCompare(kCategoryHurricane_1) == ComparisonResult.orderedSame {
                cell.categoryLabel.text = "1"
            } else if stormCenter.type?.caseInsensitiveCompare(kCategoryHurricane_2) == ComparisonResult.orderedSame {
                cell.categoryLabel.text = "2"
            } else if stormCenter.type?.caseInsensitiveCompare(kCategoryHurricane_3) == ComparisonResult.orderedSame {
                cell.categoryLabel.text = "3"
            } else if stormCenter.type?.caseInsensitiveCompare(kCategoryHurricane_4) == ComparisonResult.orderedSame {
                cell.categoryLabel.text = "4"
            } else if stormCenter.type?.caseInsensitiveCompare(kCategoryHurricane_5) == ComparisonResult.orderedSame {
                cell.categoryLabel.text = "5"
            }

            cell.categoryLabel.isHidden = false
        }
                    
    }
    
    func configureTropicsWatchCell(_ cell: TropicsWatchTableViewCell, atIndexPath indexPath: IndexPath, isFetchUpdate: Bool) {
        
        if fetchedTropicsWatchResultsController.fetchedObjects?.count == 0 {
            return
        }
        
        var correctIndexPath = indexPath
        correctIndexPath.section = 0
        
        if self.isInLineTropicsMiddleAdRecieved == true && self.adViewArray.count > 1 && indexPath.row > 0 && isFetchUpdate == false {
            correctIndexPath.row = correctIndexPath.row - 1
        }
        
        if let tropicsObject = fetchedTropicsWatchResultsController.object(at: correctIndexPath) as? TropicWatchDetail {
            
            cell.nameLabel.text = tropicsObject.name
            self.loadHTMLContent(tropicsObject.discussion, cell: cell)
            
            let imageUrl = tropicsObject.imageURL
            if imageUrl != nil {
                
                cell.tropicsImageScrollView.heightAnchor.constraint(equalToConstant: 0).isActive = false
                cell.tropicsImageScrollView.heightAnchor.constraint(equalTo: cell.contentView.widthAnchor, multiplier: 9.0/16.0).isActive = true
                cell.stormImageView.sd_setImage(with: URL(string: imageUrl!), placeholderImage: UIImage(systemName: "map")?.withTintColor(UIColor.lightGray, renderingMode: .alwaysOriginal))
           
            } else {
                cell.tropicsImageScrollView.heightAnchor.constraint(equalTo: cell.contentView.widthAnchor, multiplier: 9.0/16.0).isActive = false
                cell.tropicsImageScrollView.heightAnchor.constraint(equalToConstant: 0).isActive = true
                
                cell.stormImageView.image = nil
            }
            
            if cell.tag == 0 {
                self.imageNamePotentialWithPathArray?.removeAll()
            } else if cell.tag == 1 {
                self.imageNameSatelliteWithPathArray?.removeAll()
                print(tropicsObject.name)
                print(tropicsObject.loop_gif)
                self.loop_gif = tropicsObject.loop_gif
            } else if cell.tag == 2 {
                self.imageNameSeaTempsWithPathArray?.removeAll()
            }
            
            let indexBasedSort: NSSortDescriptor = NSSortDescriptor(key: "index", ascending: true)
            
            if tropicsObject.tropicWatchImages != nil {// HAPP-509
                let tropicWatchImagesArray: [Any] =  (tropicsObject.tropicWatchImages!.allObjects as NSArray) .sortedArray(using: [indexBasedSort])
                for tropicWatchImages: Any in tropicWatchImagesArray {
                    let imgPath = (tropicWatchImages as! TropicWatchImages).imageNameWithPath
                    if imgPath != nil {
                        if cell.tag == 0 {
                            self.imageNamePotentialWithPathArray?.append(imgPath! as AnyObject)
                        } else if cell.tag == 1 {
                            self.imageNameSatelliteWithPathArray?.append(imgPath! as AnyObject)
                        } else if cell.tag == 2 {
                            self.imageNameSeaTempsWithPathArray?.append(imgPath! as AnyObject)
                        }
                        
                    }
                }
            }
        }
        
                    
    }
    
    func loadHTMLContent(_ webContent: String?, cell: TropicsWatchTableViewCell) {
        if webContent != nil {
            let updatedContent = AppDefaults.getUpdatedContent(webContent!)
            if updatedContent != nil {
                // HAPP-449 Migrate UIWebView To WKWebView.
                let addblankLines: String! = "<p></p><p></p><p></p>"
                // added blank lines at bottom due to last line gets cut(document.body.offsetHeight)

                let cssPath: String? = Bundle.main.path(forResource: "HTMLstyling", ofType: "css")
                if cssPath != nil {
                    
                    cell.addSubview(cell.blurEffectView)
                    
                    let cssURL: URL = URL(fileURLWithPath: cssPath!)
                    cell.contentWebView.loadHTMLString((AppDefaults.getHeaderForWKWebView()!) + AppDefaults.getHTMLStringFromString( updatedContent! + addblankLines), baseURL: cssURL)
                }
            }
        }
    }
    
    func configureNotificationCell(_ cell: SailthruMessageCell, atIndexPath indexPath: IndexPath, message:BrazeKit.Braze.ContentCard) {
        
        //Create a stream impression on the message
       // STMMessageStream().registerImpression(with: STMImpressionType.streamView, for: message)
        message.context?.logImpression()
        
        cell.nameLabel.text = message.title
        cell.txtVDiscussion.text = message.description
        
        var isBannerType = false
        var imageUrl = message.classicImage?.image
        
        switch message {
            case .imageOnly(let imageOnly):
                imageUrl = imageOnly.image
                isBannerType = true
            default:
              break
        }
        
        if imageUrl != nil && isBannerType == true {
            // For banner option
            cell.stormImageView.heightAnchor.constraint(equalToConstant: 0).isActive = false
            cell.stormImageView.heightAnchor.constraint(equalTo: cell.contentView.widthAnchor, multiplier: 9.0/16.0).isActive = true
            
            cell.stormImageView.sd_setImage(with: imageUrl)
        } else if imageUrl != nil {
            // For optinal image option
            cell.stormImageView.heightAnchor.constraint(equalToConstant: 0).isActive = false
            cell.stormImageView.heightAnchor.constraint(equalTo: cell.contentView.widthAnchor, multiplier: 9.0/16.0).isActive = true
            
            cell.stormImageView.sd_setImage(with: imageUrl)
            
        } else {
            cell.stormImageView.heightAnchor.constraint(equalTo: cell.contentView.widthAnchor, multiplier: 9.0/16.0).isActive = false
            cell.stormImageView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            cell.stormImageView.image = nil
        }
        
        if isBannerType == true {
            
            cell.nameLabel.isHidden = true
            cell.txtVDiscussion.isHidden = true
            
        } else {
            
            cell.nameLabel.isHidden = false
            cell.txtVDiscussion.isHidden = false
        
        }
        
        let cardRaw = Braze.ContentCardRaw(message)
        print("url:", cardRaw.url ?? "none")
        let deepLinkURL = cardRaw.url
        
        if deepLinkURL != nil {
            
            cell.cellButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            cell.cellButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
            cell.cellButton.setTitle("READ", for: .normal)
            
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(messageStreamCellButtonTapped(_:)))
            cell.cellButton.addGestureRecognizer(tapGesture)
            
        } else {
            cell.cellButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
            cell.cellButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
        }
        
//        if (indexPath.row+1) == self.inAppMessages.count {
//            cell.seperatorLine.isHidden = true
//        } else {
            cell.seperatorLine.isHidden = false
//        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
        
        if (self.wxVideoPlayerViewController != nil) {
            if (indexPath.section == HomeSections.Livestream.rawValue) {
                self.videoPlayerRect = self.tableView.rectForRow(at: indexPath)
                
            }
        }
    }

    @objc func cellButtonTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let currentPoint: CGPoint? = gestureRecognizer.location(in: self.tableView)
        
        if currentPoint == nil {
            return
        }
        
        let indexPath: IndexPath? = self.tableView.indexPathForRow(at: currentPoint!)
        
        if indexPath == nil {
            return
        }
        
        if let hurricaneImageCell: HurricaneImageCell = self.tableView.cellForRow(at: indexPath!) as? HurricaneImageCell // happ-499
        {
            UIView.animate(withDuration: 0.038, animations: {() -> Void in
                hurricaneImageCell.alpha = 0.5
                }, completion: {(_: Bool) -> Void in
                    hurricaneImageCell.alpha = 1.0
                    self.pushToCustomDetailView(indexPath!)
            })
        }
    }
    
    @objc func cellButtonTropicsWatchedTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let currentPoint: CGPoint? = gestureRecognizer.location(in: self.tableView)
        
        if currentPoint == nil {
            return
        }
        
        let tappedIndexPath: IndexPath? = self.tableView.indexPathForRow(at: currentPoint!)
        
        if tappedIndexPath == nil {
            return
        }
        
        let cell: TropicsWatchTableViewCell = (self.tableView.cellForRow(at: tappedIndexPath!) as! TropicsWatchTableViewCell)
        self.zoomRequiredOnCell(cell)
       
    }
    
    @objc func messageStreamCellButtonTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let currentPoint: CGPoint = gestureRecognizer.location(in: self.tableView)
        let indexPath: IndexPath = self.tableView.indexPathForRow(at: currentPoint)!
        
        let message = self.inAppMessages[indexPath.row]
        self.sailthruMessageCellDidTapped(message: message as! BrazeKit.Braze.ContentCard)
    }

    @objc func livestreamVideoCellButtonTapped(_ gestureRecognizer: UITapGestureRecognizer) {

        if AppDefaults.checkInternetConnection() == false {
            self.handleNetworkError(nil, statusCode: NSURLErrorNotConnectedToInternet)
            return
        }

        if self.videoCellTapped == true {
            print("videoCellTapped")
            return
        }

        self.videoCellTapped = true
        
        let currentPoint = gestureRecognizer.location(in: self.tableView)
        
        self.livestreamTappedAtLocation(currentPoint)
    }
    
    @objc func livestreamTappedAtLocation(_ currentPoint: CGPoint) {
        
        //self.livestreamIndexPath = self.tableView.indexPathForRow(at: currentPoint)!
        self.livestreamIndexPath = IndexPath(row: 0, section: HomeSections.Livestream.rawValue)

        let selectedRow = self.livestreamIndexPath.row

        if let wxWorksVideoCell: WxVideoCustomTableViewCell = self.tableView.cellForRow(at: self.livestreamIndexPath) as? WxVideoCustomTableViewCell {
            if self.wxVideoPlayerViewController != nil {
                
                self.wxVideoPlayerViewController.removePlayer()
                self.wxVideoPlayerViewController = nil
            }
            
            wxWorksVideoCell.videoImageView.isHidden = true
            wxWorksVideoCell.playImageView.isHidden = true
            
            self.wxVideoPlayerViewController = WXVideoPlayerViewController(nibName: "WXVideoPlayerViewController", bundle: nil)
            var frame = wxWorksVideoCell.contentView.frame
            
            let height = CGFloat(kiPadRatioForVideoDisplay*UIScreen.main.bounds.width)
            frame.size.height = height
            
            self.wxVideoPlayerViewController.view.frame = frame
            
            let liveStreamObject = DataDownloadManager.sharedInstance.liveStreamArray[selectedRow]
            self.selectedLiveStreamObject = DataDownloadManager.sharedInstance.liveStreamArray[selectedRow]
           // self.selectedLiveStreamObjectIndex = selectedRow
            
          //  DataDownloadManager.sharedInstance.liveStreamArray.remove(at: selectedRow)
            let videoUrl = liveStreamObject["url"]
            
            self.wxVideoPlayerViewController.playURL = videoUrl as! String
            self.wxVideoPlayerViewController.delegate = self
            self.wxVideoPlayerViewController.delegateLandingPageVC = self
            wxVideoPlayerViewController.smallVideoFrame = frame
            self.videoFrame = frame
            wxWorksVideoCell.addSubview(self.wxVideoPlayerViewController.view)
        }
        
    }

    private func setVideoTitle(yPosition: CGFloat, labelVideoHeight: CGFloat, pCell: WxVideoCustomTableViewCell) {

        self.labelVideoTitleView = UIView(frame: CGRect(x: 0, y: yPosition, width: self.view.frame.size.width, height: labelVideoHeight))
        self.labelVideoTitleView.backgroundColor = AppDefaults.colorWithHexValue(kLandingPageTableBGColor)
        self.view.addSubview(self.labelVideoTitleView)
        
        let labelLive = UILabel(frame: CGRect(x: 20, y: pCell.liveLabel.frame.origin.y - pCell.videoImageView.frame.size.height, width: 70, height: pCell.liveLabel.frame.size.height))
        labelLive.text = "LIVE"
        labelLive.textColor = UIColor.white
        labelLive.textAlignment = .center
        labelLive.backgroundColor = UIColor(red: 200/255, green: 0, blue: 0, alpha: 1.0)
        labelLive.clipsToBounds = true
        labelLive.layer.cornerRadius = 5
        self.labelVideoTitleView.addSubview(labelLive)
        
        let labelVideoTitle = UILabel(frame: CGRect(x: 0, y: pCell.titleLabel.frame.origin.y - pCell.videoImageView.frame.size.height, width: pCell.titleLabel.frame.size.width, height: pCell.titleLabel.frame.size.height))
        let title = self.selectedLiveStreamObject["title"] as? String
        labelVideoTitle.center = CGPoint(x: self.view.center.x, y: labelVideoTitle.center.y)
        labelVideoTitle.text = title
        labelVideoTitle.textColor = UIColor.white
        labelVideoTitle.font = UIFont(name: kHurricaneFont_SemiBold, size: 20.0)
        labelVideoTitle.numberOfLines = 2
        labelVideoTitle.textAlignment = .left
        labelVideoTitle.backgroundColor = UIColor.clear
        self.labelVideoTitleView.addSubview(labelVideoTitle)
        
        // orangle line
        let orangeLineView = UIImageView(frame: CGRect(x: 0, y: pCell.separatorView.frame.origin.y - pCell.videoImageView.frame.size.height, width: self.view.frame.size.width, height: 3))
        orangeLineView.backgroundColor = UIColor.systemOrange
        self.labelVideoTitleView.addSubview(orangeLineView)
        
    }

    @objc func wxVideoAdCellButtonTapped(_ gestureRecognizer: UITapGestureRecognizer) {

        if AppDefaults.checkInternetConnection() == false {
            self.handleNetworkError(nil, statusCode: NSURLErrorNotConnectedToInternet)
            return
        }

        let currentPoint: CGPoint = gestureRecognizer.location(in: self.tableView)
        let indexPath: IndexPath = self.tableView.indexPathForRow(at: currentPoint)!

        if let wxWorksVideoCell: WxVideoCustomTableViewCell = self.tableView.cellForRow(at: indexPath) as? WxVideoCustomTableViewCell {
            if self.wxVideoPlayerViewController != nil {
                self.wxVideoPlayerViewController.removePlayer()
                self.wxVideoPlayerViewController = nil
            }

            self.wxVideoPlayerViewController = WXVideoPlayerViewController(nibName: "WXVideoPlayerViewController", bundle: nil)
            var frame = wxWorksVideoCell.contentView.frame
            // As per comment HAPP-606
            frame.origin.y = UIApplication.shared.statusBarHeight + CGFloat(kAdMobAdHeight) + 10
            frame.size.height = 220

            self.wxVideoPlayerViewController.view.frame = frame

            let videosArray = (DataDownloadManager.sharedInstance.forecastVideoDic["videos"] as? [[String: Any]])
            let videoUrl = videosArray![0]["hls"]

            self.wxVideoPlayerViewController.playURL = (videoUrl as! String)
            self.wxVideoPlayerViewController.delegate = self

            wxVideoPlayerViewController.smallVideoFrame = frame

            self.view.addSubview(self.wxVideoPlayerViewController.view)

            if self.isAdRecieved == true {
                let yPosition = frame.origin.y + self.wxVideoPlayerViewController.view.frame.size.height

                self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: yPosition, width: self.tableView.frame.size.width, height: UIScreen.main.bounds.size.height - yPosition - CGFloat(kAdMobAdHeight) - CGFloat(AppDefaults.getBottomPadding()))
            } else {
                self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: frame.origin.y + self.wxVideoPlayerViewController.view.frame.size.height, width: self.tableView.frame.size.width, height: UIScreen.main.bounds.size.height - self.wxVideoPlayerViewController.view.frame.size.height - CGFloat(AppDefaults.getBottomPadding()))
            }

        }

    }

    func pushToCustomDetailView(_ hurricaneImageCellIndexPath: IndexPath) {

        self.checkVideoPlayerIsPlaying()

        let stormCenterViewController = StormCenterViewController(nibName: "StormCenterViewController", bundle: nil)
        var tappedIndexPath = hurricaneImageCellIndexPath
        tappedIndexPath.section = 0 // HAPP-623
        let stormCenter = fetchedResultsController.object(at: tappedIndexPath) as! StormCenter
        let indexBasedSort = NSSortDescriptor(key: "index", ascending: true)
        let stormDetail = stormCenter.stormCenterDetail
        if stormDetail != nil {
            stormCenterViewController.stormCenterDetailArray = (stormDetail!.allObjects as NSArray).sortedArray(using: [indexBasedSort]) as [AnyObject]
        }
        
        self.navigationController?.pushViewController(stormCenterViewController, animated: true)
    }

    // MARK: - fetchedResultsController

    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        if fetchedResultsController != nil {
            return fetchedResultsController
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: kEntityStormCenter, in: managedObjectContext)!
        fetchRequest.entity = entity
        let sort = NSSortDescriptor(key: "stormPriority", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 20
        let theFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "Root")
        self.fetchedResultsController = theFetchedResultsController
       // self.fetchedResultsController.delegate = self
        return fetchedResultsController
    }
    
    func getFetchedTropicsResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        if self.fetchedTropicsWatchResultsController != nil {
            return self.fetchedTropicsWatchResultsController
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: kEntityTropicWatchDetail, in: self.managedObjectContext)!
        fetchRequest.entity = entity
        let sort = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 20
        let theFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "Root")
        self.fetchedTropicsWatchResultsController = theFetchedResultsController
       // self.fetchedTropicsWatchResultsController.delegate = self
        return self.fetchedTropicsWatchResultsController
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
        self.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let tableView = self.tableView
        
        if controller == self.fetchedResultsController {
            var nIndexPath: IndexPath!

            switch type {
            case NSFetchedResultsChangeType.insert:
                if newIndexPath != nil {
                    print(newIndexPath!.section)
                    nIndexPath = newIndexPath
                    nIndexPath?.section = HomeSections.Storms.rawValue // HAPP-623
                    tableView?.insertRows(at: [nIndexPath!], with: .fade)
                }
            case NSFetchedResultsChangeType.delete:
                if indexPath != nil {
                    print(indexPath!.section)
                    nIndexPath = indexPath
                    nIndexPath?.section = HomeSections.Storms.rawValue // HAPP-623
                    tableView?.deleteRows(at: [nIndexPath!], with: .fade)
                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(reloadTableDataAction), userInfo: nil, repeats: false)
                }
            case NSFetchedResultsChangeType.update:
                if indexPath != nil {
                    print(indexPath!.section)
                    nIndexPath = indexPath
                    nIndexPath?.section = HomeSections.Storms.rawValue // HAPP-623
                   
                    if tableView != nil && nIndexPath != nil {
                        self.configureCell(tableView?.cellForRow(at: newIndexPath!) as! HurricaneImageCell, atIndexPath: newIndexPath!)
                    }
                }
            case NSFetchedResultsChangeType.move:
                if indexPath != nil && newIndexPath != nil {

                    print(indexPath!.section)
                    nIndexPath = indexPath
                    nIndexPath?.section = HomeSections.Storms.rawValue // HAPP-623
                    var newIndexPath2 = newIndexPath
                    newIndexPath2?.section = HomeSections.Storms.rawValue // HAPP-623

                    tableView?.deleteRows(at: [nIndexPath!], with: .fade)
                    tableView?.insertRows(at: [newIndexPath2!], with: .fade)
                }
            @unknown default:
                print("default..")
            }

        } else if controller == self.fetchedTropicsWatchResultsController {
            
            if self.isStormsDataFound == true {
                return
            }
            
            var nIndexPath: IndexPath!

            switch type {
            case NSFetchedResultsChangeType.insert:
                if newIndexPath != nil {
                    print(newIndexPath!.section)
                    nIndexPath = newIndexPath
                    nIndexPath?.section = HomeSections.Tropics_Watch.rawValue // HAPP-623
                    tableView?.insertRows(at: [nIndexPath!], with: .fade)
                }
            case NSFetchedResultsChangeType.delete:
                if indexPath != nil {
                    print(indexPath!.section)
                    nIndexPath = indexPath
                    nIndexPath?.section = HomeSections.Tropics_Watch.rawValue // HAPP-623
                    tableView?.deleteRows(at: [nIndexPath!], with: .fade)
                }
            case NSFetchedResultsChangeType.update:
                if indexPath != nil {
                    print(indexPath!.section)
                    nIndexPath = indexPath
                    nIndexPath?.section = HomeSections.Tropics_Watch.rawValue // HAPP-623
                    
                    let cell = (tableView?.cellForRow(at: nIndexPath!) as? TropicsWatchTableViewCell)
                    
                    if cell != nil {
                        self.configureTropicsWatchCell(cell!, atIndexPath: nIndexPath!,isFetchUpdate: true)
                    }
                  
                }
            case NSFetchedResultsChangeType.move:
                if indexPath != nil && newIndexPath != nil {

                    print(indexPath!.section)
                    nIndexPath = indexPath
                    nIndexPath?.section = HomeSections.Tropics_Watch.rawValue // HAPP-623
                    var newIndexPath2 = newIndexPath
                    newIndexPath2?.section = HomeSections.Tropics_Watch.rawValue // HAPP-623

                    tableView?.deleteRows(at: [nIndexPath!], with: .fade)
                    tableView?.insertRows(at: [newIndexPath2!], with: .fade)
                }
            @unknown default:
                print("Default..")
            }

        }
      
    }
    
    @objc func reloadTableDataAction() {
        self.tableView.reloadData()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType.insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case NSFetchedResultsChangeType.delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case NSFetchedResultsChangeType.move, NSFetchedResultsChangeType.update:
            break
        @unknown default:
            print("default..")
        }

    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
        self.tableView.endUpdates()
    }

    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }

    func createBlueconicEvent() {
        let blueconicclient = BlueConic.getInstance()
        blueconicclient.updateProfile(completion: {
            BlueconicATTPluginHelper.setUpATTPlugin(blueconicclient)
        })
    }

    @objc func ShowATTPromt() {
        let application = UIApplication.shared
        if application.applicationState == UIApplication.State.active {
            if AppDefaults.getBlueconicDialogStatus() == false {

                if #available(iOS 14, *) {
                    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                        let client =  BlueConic.getInstance()
                        if status == ATTrackingManager.AuthorizationStatus.authorized {

                            BlueconicHelper.setBlueconicProfileValue("yy", forBlueconicClient: client, forProperty: AppDefaults.getBlueconicPropertyName() ?? "")
                        } else if status == ATTrackingManager.AuthorizationStatus.denied {
                            BlueconicHelper.setBlueconicProfileValue("yn", forBlueconicClient: client, forProperty: AppDefaults.getBlueconicPropertyName() ?? "")

                        }

                    })
                }
            }
        } else {
            perform(#selector(self.ShowATTPromt), with: self, afterDelay: 1)
        }
    }

    // Video player delegate
    func videoPlayerViewDidClose() {
      
        if self.topSponsorShipView != nil {
            self.topSponsorShipView.removeFromSuperview()
        }
        
        if let wxWorksVideoCell: WxVideoCustomTableViewCell = self.tableView.cellForRow(at: self.livestreamIndexPath) as? WxVideoCustomTableViewCell {
            wxWorksVideoCell.videoImageView.isHidden = false
            wxWorksVideoCell.playImageView.isHidden = false
        }

        self.tableView.reloadData()

        if self.isAdRecieved == true {
            
            self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y:CGFloat(UIApplication.shared.statusBarHeight), width: self.tableView.frame.size.width, height: UIScreen.main.bounds.size.height - UIApplication.shared.statusBarHeight - CGFloat(kAdMobAdHeight) - CGFloat(AppDefaults.getBottomPadding()))

        } else {
            
            if let tabCtrl = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {

                self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: CGFloat(UIApplication.shared.statusBarHeight), width: self.tableView.frame.size.width, height: UIScreen.main.bounds.size.height - UIApplication.shared.statusBarHeight - tabCtrl.tabBar.frame.size.height)
            }
            
        }

        if self.wxVideoPlayerViewController != nil {
            self.wxVideoPlayerViewController.view.removeFromSuperview()

            self.wxVideoPlayerViewController = nil
        }

    }

    func videoPlayerViewDidDisplay() {

    }

    func loadingIndicatorDismiss() {
        self.videoCellTapped = false
    }
    func videoPlayerPresentFullScreen() {
        self.isLandscapeRequired = true
        
        if (self.wxVideoPlayerViewController != nil) {
            let window = UIApplication.shared.keyWindow
            window!.addSubview(self.wxVideoPlayerViewController.view)
            self.wxVideoPlayerViewController.view.frame = UIScreen.main.bounds
            //self.wxVideoPlayerViewController.playerLayer?.frame = UIScreen.main.bounds
            self.wxVideoPlayerViewController.playerViewController.view.frame = UIScreen.main.bounds
           
            self.wxVideoPlayerViewController.contentPlayer?.play()
            
        }

        AppDefaults.hideTabbar()
    }

    func videoPlayerDismissFullScreen() {
        self.isLandscapeRequired = false
        
        if let wxWorksVideoCell: WxVideoCustomTableViewCell = self.tableView.cellForRow(at: self.livestreamIndexPath) as? WxVideoCustomTableViewCell {
            wxWorksVideoCell.addSubview(self.wxVideoPlayerViewController.view)
        }

        self.rotateToPotraitScapeDevice()
        AppDefaults.showTabbar()
       
        if self.isAdRecieved == true {
            self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.size.width, height: UIScreen.main.bounds.size.height - self.tableView.frame.origin.y - CGFloat(kAdMobAdHeightForBanner))
        } else {
            
            if let tabCtrl = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.size.width, height: UIScreen.main.bounds.size.height - self.tableView.frame.origin.y - tabCtrl.tabBar.frame.size.height)
                
            }
        }
    }
    
    private func sailthruMessageCellDidTapped(message: BrazeKit.Braze.ContentCard) {
        
        message.context?.logClick()
        
        let cardRaw = Braze.ContentCardRaw(message)
        print("url:", cardRaw.url ?? "none")
        
        if cardRaw.url == nil {
            return
        }
        
            if let messageURL = cardRaw.url?.absoluteString {
        
//                   // Put your code which should be executed with a delay here
                    let webLinkViewController = StationHeadlinesViewController(nibName: "StationHeadlinesViewController", bundle: nil)
                    webLinkViewController.stationHeadlinesURL = messageURL
                    webLinkViewController.screenTitle = ""
                    self.navigationController?.navigationBar.isHidden = false

                    self.navigationController?.pushViewController(webLinkViewController, animated: true)
                }
    }
    
    private func rotateToPotraitScapeDevice() {

            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIView.setAnimationsEnabled(true)

    }
    
    // MARK: - GAMBannerview delegate
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
        
        if bannerView.tag == 1 {
            self.adViewArray.append(bannerView as! GAMBannerView)
            self.isInLineAdRecieved = true
        } else if bannerView.tag == 2 {
            self.adViewArray.append(bannerView as! GAMBannerView)
            self.isInLineTropicsMiddleAdRecieved = true
            
            self.loadInlineAd(indexCount: 3)
        } else if bannerView.tag == 3 {
            self.adViewArray.append(bannerView as! GAMBannerView)
            self.isInLineTropicsBottomAdRecieved = true
        }
        
        
        self.tableView.reloadData()
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        if bannerView.tag == 1 {
            self.isInLineAdRecieved = false
        } else if bannerView.tag == 2 {
            self.isInLineTropicsMiddleAdRecieved = false
            self.loadInlineAd(indexCount: 3)
        } else if bannerView.tag == 3 {
            self.isInLineTropicsBottomAdRecieved = false
        }
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
    
    @objc func resetGoogleMobileBannerAdFlag(_ notificationObject: Foundation.Notification) {
        // App was gone in background
        self.isAppBackground = true
    }

    func loadVideo(_ videoURL:URL) {
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    @objc func playerDidFinishPlaying() {
        print("Video Finished playing")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ImageViewControllerDelegate
    func imageViewDidDisplay() {
        self.isLandscapeRequired = true
    }

    func imageViewDidClose() {
        self.isLandscapeRequired = false
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc func performClickOnAdImage() {
        self.topSponsorCustomADBanner.performClickOnAsset(withKey: "Image")
        self.topSponsorCustomADBanner.performClickOnAsset(withKey: "ImageFile")
    }
    
    // MARK: - Scrollview delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.handleLivestreamPlayer()
        
    }
    
    private func handleLivestreamPlayer() {
        
        if (self.wxVideoPlayerViewController != nil) {
            if (self.wxVideoPlayerViewController.isPipIsActive) {
                return
            }
        }
        
        if (shouldAdjustVideoFrame == nil || videoFrame == nil || videoPlayerRect == nil) {
            return
        }
        
        if(!shouldAdjustVideoFrame && self.tableView.contentOffset.y >= (videoFrame.origin.y - AppDefaults.getTopPadding()) && (self.wxVideoPlayerViewController != nil) && (((self.wxVideoPlayerViewController != nil) && self.tableView.contentOffset.y >= (videoPlayerRect.origin.y+self.wxVideoPlayerViewController.view.frame.origin.y - AppDefaults.getTopPadding())))) {
            
            shouldAdjustVideoFrame = true
            self.pinnedFrame = self.videoPlayerRect
          
            self.pinnedFrame.origin.y = videoPlayerRect.origin.y+self.wxVideoPlayerViewController.view.frame.origin.y;
                var frame = self.wxVideoPlayerViewController.view.frame;
                frame.origin.y =  AppDefaults.getTopPadding()

            self.wxVideoPlayerViewController.view.frame = frame;
            self.view.addSubview(self.wxVideoPlayerViewController.view)
        } else if ((pinnedFrame != nil) && (self.tableView.contentOffset.y < (pinnedFrame.origin.y - AppDefaults.getTopPadding())) && shouldAdjustVideoFrame && (self.wxVideoPlayerViewController != nil)){
            print("Video player unpinned \(self.tableView.contentOffset.y), \(pinnedFrame.origin.y)");
         
            shouldAdjustVideoFrame = false;
            self.wxVideoPlayerViewController.view.frame = videoFrame;

            if let wxWorksVideoCell: WxVideoCustomTableViewCell = self.tableView.cellForRow(at: self.livestreamIndexPath) as? WxVideoCustomTableViewCell {
               
                wxWorksVideoCell.addSubview(self.wxVideoPlayerViewController.view)
                self.videoFrame = self.wxVideoPlayerViewController.smallVideoFrame
            }
            
        }
    }
    
    func livestreamPiPClose(completionHandler : ((Bool) -> Void)? = nil) {
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
            //Animations
            self.tableView.reloadData()
            
        }) { [self] (finished) in
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
                //Animations
                self.resetLivestreamPlayerFrame()
                
            }) { [self] (finished) in
                
                let indexPath = IndexPath(row: 0, section: HomeSections.Livestream.rawValue)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                if ((completionHandler) != nil) {
                    completionHandler!(true)
                }
            }
          
        }
    }
    
    func livestreamPiPStart() {
        self.tableView.reloadData()
        
        if (shouldAdjustVideoFrame) {
            self.wxVideoPlayerViewController.view.isHidden = true
        }
    }
    
    private func resetLivestreamPlayerFrame() {
        if (!self.wxVideoPlayerViewController.isPipIsActive) {
            self.wxVideoPlayerViewController.view.isHidden = false
        }
        
        var frame = self.wxVideoPlayerViewController.view.frame
        let height = CGFloat(kiPadRatioForVideoDisplay*UIScreen.main.bounds.width)
        frame.size.height = height
        self.wxVideoPlayerViewController.view.frame = frame
    }
    
}

extension UIViewController {
    
    func takeSnapShotOfView() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.snapShotAllowed == true {
            if appDelegate.settingTableViewController.moreSettingViewController?.snapShotView != nil {
                appDelegate.settingTableViewController.moreSettingViewController?.snapShotView.removeFromSuperview()
            }
            appDelegate.settingTableViewController.moreSettingViewController?.snapShotView = AppDefaults.customSnapshotFromView(inputView: self.view)
            appDelegate.snapShotAllowed = false
        }
    }
}
