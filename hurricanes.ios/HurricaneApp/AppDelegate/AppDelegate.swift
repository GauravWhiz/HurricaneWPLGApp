//
//  AppDelegate.swift
//  Hurricane
//
//  Created by Swati Verma on 08/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//
import Foundation
import UIKit
import Reachability

import UserNotifications
import Firebase
import StoreKit
import BlueConicClient
import BrazeKit
import BrazeLocation

let kDisplayActiveHurricane: String = "DisplayActiveHurricane"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate, UNUserNotificationCenterDelegate, UITabBarControllerDelegate, FirebaseRemoteConfigDelegate {
    var window: UIWindow?

    let kHurricaneDataDownloaded: String = "HurricaneDataDownloaded"
    let kDataDownLoadFailed: String = "DataDownLoadFailed"
    let kStormUpdateTitle = "Storm Update"
    let kCancelTitle = "Not Now"
    let kShowTitle = "View"
    let kAlertMessageKey = "alert"
    let kAlertTitleKey = "title"
    let kAlertBodyKey = "body"
    var notificationUserInfo: [AnyHashable: Any]?
    var activeStormId: NSString?
    var reachability: Reachability?
    var tabBarController : TabBarController?
    @objc var isBlueConicDialogVisible = false
    var settingTableViewController:SettingsViewController!
    var snapShotAllowed = false
    
    // braze
    static var braze: Braze?
    // The subscription needs to be retained to be active.
    var cardsSubscription: Braze.Cancellable?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let pathAndFileName: String = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") ?? ""
        if FileManager.default.fileExists(atPath: pathAndFileName) == true {
            FirebaseApp.configure()
        }

        // firebase remote config setup
        FirebaseRemoteConfig.sharedInstance().initSetup()

        self.setBlueconicDefaultProfileProperties()
        // Increment usage count
        self.incrementUsageCount()

        self.window = UIWindow(frame: UIScreen.main.bounds)

        // Override point for customization after application launch.
        self.setNavigationBarItems()
        self.setSegmentedControlItems()
        
        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        self.initBrazeSDK()
        self.registerSettingsAndCategories()
            
            FirebaseRemoteConfig.sharedInstance().delegate = self
          
            let defaults = UserDefaults.standard
            if defaults.bool(forKey: kCarnivalChannelsSubscribed) {
                let channels = defaults.value(forKey: kCustomAttributeName) as? [String]
                let channelsSailthruExistingUsers = defaults.value(forKey: "channels") as? [String]
                if channels != nil {

                    AppDelegate.braze?.user.setCustomAttribute(key: kCustomAttributeName, array: channels!)
                    
                } else if channelsSailthruExistingUsers != nil {
                    // will register old sailthru users to braze users
                    print(channelsSailthruExistingUsers)
                    AppDelegate.braze?.user.setCustomAttribute(key: kCustomAttributeName, array: channelsSailthruExistingUsers!)
                    defaults.set(channelsSailthruExistingUsers, forKey: kCustomAttributeName)
                    defaults.synchronize()
                } else {
                    let channelArray = [kAllStormsChannel, kMetsUpdateChannel]
                    
                    AppDelegate.braze?.user.setCustomAttribute(key: kCustomAttributeName, array: channelArray)
            
                    //print("Channels registered on Carnival")
                    defaults.set(channelArray, forKey: kCustomAttributeName)
                    defaults.synchronize()
                }

            }

        /* Start CoreLocation Service */
        CoreLocationManager.sharedInstance.startUpdatingLocation()
       
        /* Start Google Analytics */
        self.initializeGoogleAnalytics()
        // HAPP-493? Update ComScore to V6.3.2.200511
        /*Initialize ComScore */
        let customerC2 = AppDefaults.getC2Value()
        
        if (customerC2.count != 0) {
            let publisherConfig = SCORPublisherConfiguration(builderBlock: { builder in
                builder?.publisherId = customerC2
            })
            
            let customerC4 = AppDefaults.getC4Value()
            if (customerC4.count != 0) {
                SCORAnalytics.configuration().applicationName = customerC4
            }
            
            SCORAnalytics.configuration().addClient(with: publisherConfig)
            SCORAnalytics.configuration().usagePropertiesAutoUpdateInterval = 300
            SCORAnalytics.start()
        }

        let userInfo: [AnyHashable: Any]? = (launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any])
        self.setLandingPageItems(userInfo)

        /* Starting Notifier to get notified of network changes */
        self.reachability = Reachability.forInternetConnection()
        if self.reachability != nil {
            self.reachability!.startNotifier()
        }

        self.window?.makeKeyAndVisible()
        self.window?.clipsToBounds = true
        
        self.printCurrentContentCards()

        return true
    }
    
    func initBrazeSDK() {
       
        let configuration = Braze.Configuration(apiKey: AppDefaults.getBrazeAPIKey(), endpoint: AppDefaults.getBrazeEndpoint())
        configuration.logger.level = .info
        configuration.location.brazeLocationProvider = BrazeLocationProvider()
        configuration.location.automaticLocationCollection = true
       // configuration.push.appGroup = "Graham Media Group - Development"
        let braze = Braze(configuration: configuration)
        AppDelegate.braze = braze
      
    }

    func printCurrentContentCards() {
        
        self.cardsSubscription = AppDelegate.braze?.contentCards.subscribeToUpdates { cards in
          print("cardsSubscription cards subscribe:", cards)
        }
        
        AppDelegate.braze?.contentCards.requestRefresh { result in
          switch result {
          case .success(let cards):
         
              guard let cardnew = cards.first else { return }
              
              switch cardnew {
              case .classic(let classic):
                  print("classic - title:", classic.title)
              case .imageOnly(let imageOnly):
                  print("banner - image:", imageOnly.image)
              case .control:
                  print("control")
              default:
                  break
              }
              
              if let title = cardnew.classic?.title {
                print("classic - title:", title)
              }
              
          case .failure(let error):
            print("error:", error)
          }
        }
        
        print(AppDelegate.braze?.contentCards.cards ?? [])
        
        guard let card = AppDelegate.braze?.contentCards.cards.first else { return }
        
        // To access card specific fields, you can switch on the `card` enum:
        switch card {
        case .classic(let classic):
          print("classic - title:", classic.title)
        case .imageOnly(let imageOnly):
          print("banner - image:", imageOnly.image)
        default:
          break
        }

        // Braze.ContentCard is an enum representing the different kind of content cards supported by
        // the Braze platform.
        //
        // All `Braze.ContentCard` have a `.data` property that contains common fields.
        // For instance, you can retrieve the `extras` dictionary / `url` on all content cards:

        if let title = card.classic?.title {
          print("classic - title:", title)
        }
        
        if let description = card.classic?.description {
          print("classic - title:", description)
        }
        
//        if let title2 = card.classic?.data.title {
//            print("classic - title2:", title2)
//        }
        
//        if let description = card.classic?.description {
//          print("classic - description:", description)
//        }

        if let image = card.imageOnly?.image {
          print("banner - image:", image)
        }

        // A wrapper / compatibility representation of the card is accessible via `.json()`
        if let jsonData = card.json(),
          let jsonString = String(data: jsonData, encoding: .utf8) {
          print(jsonString)
        }

        // A card can always be transformed into a `Braze.ContentCardRaw`, a compatibility
        // representation of the Content Card type.
        let cardRaw = Braze.ContentCardRaw(card)
        print("extras:", cardRaw.title ?? "ccc")
        print("extras:", cardRaw.extras)
        print("url:", cardRaw.url ?? "none")
      
      /*  guard let card2 = AppDelegate.braze?.contentCards.cards[1] else { return }

        // Braze.ContentCard is an enum representing the different kind of content cards supported by
        // the Braze platform.
        //
        // All `Braze.ContentCard` have a `.data` property that contains common fields.
        // For instance, you can retrieve the `extras` dictionary / `url` on all content cards:

        if let title2 = card2.classic?.title {
          print("classic - title:", title2)
        }
        
        if let description2 = card2.classic?.description {
          print("classic - description:", description2)
        }*/
        
    }
    func setBlueconicDefaultProfileProperties() {

        /* The current authorization status. If the user has not yet been                                   prompted to approve access, the return value will either be
         * ATTrackingManagerAuthorizationStatusNotDetermined, or ATTrackingManagerAuthorizationStatusRestricted if this value is managed.
         * Once the user has been prompted, the return value will be either ATTrackingManagerAuthorizationStatusDenied or ATTrackingManagerAuthorizationStatusAuthorized.
         */

        let client = BlueconicHelper.getBlueconicClient(self)
        BlueconicATTPluginHelper.setUpATTPlugin(client)

    }
    func registerSettingsAndCategories() {
        // Configure other actions and categories and add them to the set...
        if #available(iOS 10.0, *) {
           
            Braze.Notifications.categories = Set<UNNotificationCategory>()
            let readMoreAction = [UNNotificationAction.init(identifier: "readAction", title: "Read", options: UNNotificationActionOptions.foreground)]

            let hurricaneCategory = UNNotificationCategory(identifier: "hurricane",
                                                           actions: readMoreAction,
                                                           intentIdentifiers: [],
                                                           options: [])
            //categories.insert(hurricaneCategory)
            Braze.Notifications.categories.insert(hurricaneCategory)
            
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.setNotificationCategories(Braze.Notifications.categories)
            center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, _) in
                // Enable or disable features based on authorization.
                AppDefaults.setPushNotificationPermissionStatus(isPermission: granted)
                
                if granted {
                    print("Permission granted")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    print("Permission denied")
                }
            }
        } else {
            var categories = Set<UIUserNotificationCategory>()
            let readMoreAction: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
            readMoreAction.title = "Read"
            readMoreAction.identifier = "readAction"
            readMoreAction.activationMode = .foreground
            readMoreAction.isAuthenticationRequired = false
            let hurricane: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            hurricane.setActions([readMoreAction], for: .default)
            hurricane.identifier = "hurricane"
            categories.insert(hurricane)
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: categories)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }

    func initializeGoogleAnalytics() {
        let pathAndFileName: String? = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        if pathAndFileName != nil {
            if FileManager.default.fileExists(atPath: pathAndFileName!) {
                if let gai = GAI.sharedInstance() {
                    gai.trackUncaughtExceptions = true  // report uncaught exceptions
                    gai.dispatchInterval = 20
                    gai.logger.logLevel = GAILogLevel.verbose
                    let googleTrackingId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: VAR_GA_TRACKING_ID) as? String
                    if googleTrackingId != nil && googleTrackingId != "" {
                        gai.tracker(withTrackingId: googleTrackingId!)
                    }

                    guard let tracker = gai.defaultTracker else { return }
                    // Enable Advertising Features.
                    tracker.allowIDFACollection = true
                }
            }
        }
    }

    func setLandingPageItems(_ userInfo: [AnyHashable: Any]?) {
        /* LANDING PAGE */
        var homeViewController: UIViewController
        if AppDefaults.needsUpdate() {
            homeViewController = UpgradeViewController()
            MBProgressHUD.hide(for: self.window, animated: true)
        } else {
            homeViewController = LandingPageViewController(nibName: "LandingPageViewController", bundle: nil)
            /*Start activity indicator and data downloading*/
           
        }
        
        homeViewController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "tab_home_inactive"),
            tag: 1)
        
        let stormsListController = StormsListViewController(nibName: "StormsListViewController", bundle: nil)
        stormsListController.tabBarItem = UITabBarItem(
            title: "Storms",
            image: UIImage(named: "tab_strome"),
            tag: 2)
        
        let tropicWatchViewController = TropicWatchViewController(nibName: "TropicWatchViewController", bundle: nil)
        tropicWatchViewController.isTropicsWatch = true
        tropicWatchViewController.tabBarItem = UITabBarItem(
            title: "Tropics",
            image: UIImage(named: "tropics"),
            tag: 3)
        
        let stromTrackerViewController = LiveMapViewController(nibName: "LiveMapViewController", bundle: nil)
        stromTrackerViewController.isLocalRadar = false
        stromTrackerViewController.tabBarItem = UITabBarItem(
            title: "Tracker",
            image: UIImage(named: "tab_tracker"),
            tag: 4)
        
        self.settingTableViewController = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.settingTableViewController.tabBarItem = UITabBarItem(
            title: "More",
            image: UIImage(named: "tab_more"),
            tag: 5)
        
        let navHome = UINavigationController(rootViewController: homeViewController)
        navHome.navigationBar.isHidden = true
       
        let navStormsList = UINavigationController(rootViewController: stormsListController)
        let navTropicsWatch = UINavigationController(rootViewController: tropicWatchViewController)
        let navTracker = UINavigationController(rootViewController: stromTrackerViewController)
        let navAlertSettings = UINavigationController(rootViewController: self.settingTableViewController)
        
        let controllers = [navHome,navStormsList,navTropicsWatch, navTracker, navAlertSettings]
        
        self.tabBarController = TabBarController()
        tabBarController!.viewControllers = controllers
        tabBarController?.delegate = self
     
        window?.rootViewController = tabBarController
    }

    func setNavigationBarItems() {
        var navColor = AppDefaults.hexStringToUIColor("#0E3C63")
        UINavigationBar.appearance().barTintColor = navColor
        navColor = AppDefaults.hexStringToUIColor("ffffff")
        UINavigationBar.appearance().tintColor = navColor
        let titleDict: NSDictionary = [NSAttributedString.Key.foregroundColor: navColor, NSAttributedString.Key.font: UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 22 : 18))!]
        UINavigationBar.appearance().titleTextAttributes = titleDict as? [NSAttributedString.Key: Any]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 22 : 18))!], for: UIControl.State())

        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance() .shadowImage = UIImage()
        UINavigationBar.appearance().barStyle = UIBarStyle.black
    }

    func setSegmentedControlItems() {
        var segmentItemAttributes: [AnyHashable: Any]? = (UISegmentedControl.appearance().titleTextAttributes(for: UIControl.State()))
        if segmentItemAttributes != nil {
            segmentItemAttributes![NSAttributedString.Key.font] = UIFont(name: kHurricaneFont_Medium, size: 13)// size: kSegmentItemFontSize)
            segmentItemAttributes![NSAttributedString.Key.foregroundColor] = AppDefaults.colorWithHexValue(0xF2F3F4)
            segmentItemAttributes![NSAttributedString.Key.kern] = -0.4
            UISegmentedControl.appearance().setTitleTextAttributes(segmentItemAttributes! as? [NSAttributedString.Key: Any], for: UIControl.State())
            UISegmentedControl.appearance().setTitleTextAttributes(segmentItemAttributes! as? [NSAttributedString.Key: Any], for: .selected)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
       // NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kNotificationGoogleBannerADReset), object: nil, userInfo: nil)
        
        if !(AppDefaults.needsUpdate()) {
        //    DataDownloadManager.sharedInstance.downloadAllData()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.showRatingPopUp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        AppDefaults.setDeviceToken(token: deviceToken)
        // register with Braze SDK
        AppDelegate.braze?.notifications.register(deviceToken: deviceToken)
        
        print("Device token")
        print(deviceToken.hexString)
        self.initCarnivalSetUp()

    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotifications - %@", error)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        BlueConic.getInstance(nil).setURL(url)
        self.activeStormId = url.query as NSString?
        if self.activeStormId == nil {
            return true
        }
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.window, animated: true)
        hud.labelText = kHUDLabelText

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(2 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
            self.downloadActiveHurricaneData()
        })
        return true
    }

    func downloadActiveHurricaneData() {
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.dataDownloadingDone), name: NSNotification.Name(rawValue: kHurricaneDataDownloaded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.dataDownloadingDone), name: NSNotification.Name(rawValue: kDataDownLoadFailed), object: nil)
        DataDownloadManager.sharedInstance.downloadAllData()
    }

    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        
        self.notificationUserInfo = notification.request.content.userInfo
        let apsDict = self.notificationUserInfo!["aps"] as? NSDictionary
        
        if apsDict != nil {
            if let alertString = apsDict?[kAlertMessageKey] as? String {
                self.showAlert(kStormUpdateTitle, message: alertString)
            } else {
                if let alertObj = apsDict?[kAlertMessageKey] as? NSDictionary {
                    
                    if let alertTitle =  alertObj[kAlertTitleKey] as? String {
                        
                        if let alertBody =  alertObj[kAlertBodyKey] as? String {
                            self.showAlert(alertTitle, message: alertBody)
                        }
                        
                    } else {
                        self.showAlert(kStormUpdateTitle, message: "Alert")
                    }
                } else {
                    self.showAlert(kStormUpdateTitle, message: "Alert")
                }
            }
        }
        completionHandler([])
    }

    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        // Pass the notification response to the SDK.
        
        if let braze = AppDelegate.braze,
          braze.notifications.handleUserNotification(
            response: response,
            withCompletionHandler: completionHandler
          ) {
        //  return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let userInfo = response.notification.request.content.userInfo
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kNotificationPush), object: nil, userInfo: userInfo)
            
        }
               
        completionHandler()
        
    }

    func showAlert(_ title: String, message: String) {
        let strContent = AppDefaults.getUpdatedContent(message)
        let alert = UIAlertController(title: title, message: strContent, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Show", style: UIAlertAction.Style.default) {
            _ in

            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kNotificationPush), object: nil, userInfo: self.notificationUserInfo)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            _ in
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kNotificationSailthru), object: nil, userInfo: nil)
        }

        // Add the actions
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        if (self.window!.rootViewController) != nil &&
            (self.window!.rootViewController!.isKind(of: UINavigationController.self)) {
            let presentedViewController = (self.window!.rootViewController as! UINavigationController).viewControllers.last! as UIViewController
            presentedViewController.present(alert, animated: true, completion: nil)
        } else if (self.window!.rootViewController) != nil &&
            (self.window!.rootViewController!.isKind(of: UITabBarController.self)) {
            
            let selectedNavController = (self.window!.rootViewController as! UITabBarController).selectedViewController
            if selectedNavController != nil {
                let presentedViewController = (selectedNavController as! UINavigationController).viewControllers.last! as UIViewController
                presentedViewController.present(alert, animated: true, completion: nil)
            }
        }
        
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if (self.window!.rootViewController) != nil &&
            (self.window!.rootViewController!.isKind(of: UINavigationController.self)) {
            let presentedViewController = (self.window!.rootViewController as! UINavigationController).viewControllers.last! as UIViewController
            return presentedViewController.supportedInterfaceOrientations
        } else if (self.window!.rootViewController) != nil &&
            (self.window!.rootViewController!.isKind(of: UITabBarController.self)) {
            
            let selectedNavController = (self.window!.rootViewController as! UITabBarController).selectedViewController
            if selectedNavController != nil {
                let presentedViewController = (selectedNavController as! UINavigationController).viewControllers.last! as UIViewController
                return presentedViewController.supportedInterfaceOrientations
            } else {
                return UIInterfaceOrientationMask.portrait
            }
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }

    @objc func dataDownloadingDone() {
        MBProgressHUD.hide(for: self.window, animated: true)
        if self.activeStormId != nil {
            let userInfo: [AnyHashable: Any] = [
                "stormId": self.activeStormId!
            ]
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kDisplayActiveHurricane), object: nil, userInfo: userInfo)
        }

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kHurricaneDataDownloaded), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kDataDownLoadFailed), object: nil)
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    }

    func showRatingPopUp() {
        let usageCount =  (UserDefaults.standard.object(forKey: "RATING_USAGE_COUNT_KEY") as? Int) ?? 0
        if usageCount >= AppDefaults.getMinimumUsageForRating() {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.removeObject(forKey: "RATING_USAGE_COUNT_KEY")
                UserDefaults.standard.synchronize()
            }
        }
    }

    func incrementUsageCount() {
        let value =  UserDefaults.standard.object(forKey: "RATING_USAGE_COUNT_KEY") as? Int
        var usageCount = 0
        if  value != nil {
            usageCount = value!
        }
        UserDefaults.standard.set(usageCount+1, forKey: "RATING_USAGE_COUNT_KEY")
        UserDefaults.standard.synchronize()
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        URLCache.shared.removeAllCachedResponses()

        // Clear Cache
        let sharedCache: URLCache = URLCache.init(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        URLCache.shared = sharedCache
        sharedCache.removeAllCachedResponses()

        // Clear Cookies
        let cookieJar = HTTPCookieStorage.shared
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }

        UserDefaults.standard.synchronize()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let presentedViewController = (viewController as! UINavigationController).viewControllers.last! as UIViewController
        
        if let firstVC =  presentedViewController as? SettingsViewController {
            self.snapShotAllowed = true
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

        let selectedNavController = self.tabBarController!.selectedViewController
        if selectedNavController != nil {
            let presentedViewController = (selectedNavController as! UINavigationController).viewControllers.last! as UIViewController
            
            if let firstVC =  presentedViewController as? SettingsViewController {
                if(AppDefaults.getMoreTabStatus() == false) {
                    AppDefaults.setMoreTabStatus(status: true)
                    if let snapView = self.settingTableViewController.moreSettingViewController?.snapShotView {
                        self.settingTableViewController.view.addSubview(snapView)
                    }
                     
                    firstVC.RemoveChildView()
                    firstVC.showMenuView()
                } else if(AppDefaults.getisChildViewAdded()) {
                    if(firstVC.ismenuOpen) {
                        firstVC.closeMenuView()
                    } else {
                        
                        firstVC.showMenuView()
                    }
                } else {
                    AppDefaults.setMoreTabStatus(status: false)
                    firstVC.closeMenuView()
                    AppDefaults.setIsChildViewAdded(status: false)
                    self.tabBarController?.selectedIndex = AppDefaults.getSelectedIndex()
                }
            } else {
                AppDefaults.setSelectedIndex(index: tabBarController.selectedIndex)
                AppDefaults.setMoreTabStatus(status: false)
                AppDefaults.setIsChildViewAdded(status: false)
                moreSettingsSelectedIndexPath = IndexPath()
                
                if let firstVC =  presentedViewController as? LandingPageViewController {
                    if self.tabBarController!.isPushReceived == true {
                        firstVC.refreshData()
                        self.tabBarController!.isPushReceived = false
                    }
                } else if presentedViewController is StormCenterViewController {
                    (selectedNavController as! UINavigationController).popToRootViewController(animated: false)
                }
            }
            
        } else {
            AppDefaults.setSelectedIndex(index: tabBarController.selectedIndex)
            AppDefaults.setMoreTabStatus(status: false)
            AppDefaults.setIsChildViewAdded(status: false)
            moreSettingsSelectedIndexPath = IndexPath()
            
            
        }
    }
    
    func configDownloadComplete() {
        DispatchQueue.main.async(execute: {() -> Void in
           //self.initCarnivalSetUp()
        })
    }

    func initCarnivalSetUp() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: kCarnivalChannelsSubscribed) {

                let deviceToken = AppDefaults.getDeviceToken()
                if deviceToken != nil {
                    AppDefaults.registerChannels()
                }
        }
    }
    
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
