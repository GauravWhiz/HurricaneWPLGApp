//
//  AppDefaults.swift
//  Hurricane
//
//  Created by Swati Verma on 08/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation
import Reachability
import UIKit

var isMoreTabSelected = false
var isChildViewAdded = false
var SelectedIndex = 0
/* DETERMINE IF APP IS RUNNING ON IPAD */
let IS_IPAD = (UIDevice.current.userInterfaceIdiom == .pad)
let kPROPERTY_ATT_NEWS   =  "att_demonews" // value taken from blueconic website.
/* NAVIGATION RELATED ITEMS */
let kNavigationBarImage = "var_brand.png"
let kNavigationBarImageForIphone6 = "var_brand~iphone6.png"
let kRefreshDataButtonImage = "refreshDataButton.png"
let kNavigationBarButtonColor_iOS7 = 0xFFFFFF
let kNvigationBarItemFontSize = 12
let kIphone6Width: Float = 375.0
let navigationBarHeight: CGFloat = (IS_IPAD ? 47 : 44)

/* SEGMENT CONTROL */
let kSubHeaderColor = 0xD0D2D3
let kSegmentItemColor = 0xF2F3F4
let kSegmentBGColor = 0x6A7580

let kSegmentItemFontSize = (IS_IPAD ? 30 : 13)
let kSegmentControlHeight = (IS_IPAD ? 54 : 27)
let kCustomHeaderLabelFontSize = (IS_IPAD ? 61 : 31.61)
let kCustomSubHeaderLabelFontSize = (IS_IPAD ? 31 : 15.79)
let kSegmentContentPosition_Y = (IS_IPAD ? -25 : -8)

/* RESOURCE FILES */
let kInteractiveMapPlugin = "InteractiveMapPlugin"

/* TABLE IMAGES */
let kMapBackgroundImage = "defaultBackground.png"

/* ACTIVE HURRICANES IMAGES */
let kHurricaneBackgroundImage = "hurricaneCategoryBG.svg"
let kWXVideoAdPlayImage = "videoPlayIcon.svg"

/* DEFAULT FONTS */
let kHurricaneFont_Bold = "Cabin-Bold"
let kHurricaneFont_SemiBold = "Cabin-SemiBold"
let kHurricaneFont_Medium = "Cabin-Medium"
let kHurricaneFont_Regular = "Cabin-Regular"
let kHurricaneFont_Italic = "Cabin-Italic"

/* DEFAULT COLORS */
let kLabelColor = 0xFFFFFF
let kImageBorderColor = 0x85919A
let kSubLabelColor = 0xCBCED0
let kLabelGreenColorDark = 0x678A4A
let kLabelGreenColorLight = 0x2A4739
let kPullToRefreshColor = 0xbbb9b5
let kBackgroundColor = 0x011b2d
let kLandingPageTableBGColor = 0x001b2e
let kWebViewControlsBgColor = 0x001b2e
let kWebViewLoadingBgColor = 0x28334f
let borderColor = UIColor(red: 36/255.0, green: 107/255.0, blue: 210/255.0, alpha: 1)
let backgroundColor = UIColor(red: 12/255.0, green: 43/255.0, blue: 70/255.0, alpha: 1)

let kWxWorksCellBgColor = 0x184242
let kBarButtonColor = 0x1A6BE1
let kStationCellBgColor = 0x3B6994
/* MISCELLANEOUS */
func getUIColorFromRGB(_ rgbValue: Int) -> UIColor {
   return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0xFF) / 255.0, alpha: 1.0)
}
let UIColorFromRGB = getUIColorFromRGB

/* ADMOB UNIT IDs */
let kAdMobAdHeight = IS_IPAD ? 90:50

/* CORE DATA RELATED ENTITIES */
let kEntityTropicWatch = "TropicWatch"
let kEntityTropicWatchDetail = "TropicWatchDetail"
let kEntityTropicWatchImages = "TropicWatchImages"

let kEntityWatchesAndWarnings = "WatchesAndWarnings"
let kEntityWatchesAndWarningsDetail = "WatchesAndWarningsDetail"

let kEntityLiveStream = "LiveStream"
let kEntityNotifications = "Notification"
let kEntityStormCenter = "StormCenter"
let kEntityStormCenterDetail = "StormCenterDetail"
let kEntityStormCenterImages = "StormCenterImages"

/* PARSE CHANNEL INFORMATION FOR PUSH ALERTS */
let kAllStormsChannel = "AllStorms"
let kMetsUpdateChannel = "MetsUpdates"
let kLocalStormsChannel = "LocalStorms"

let kAllStormsKey = "AllStorms"
let kLocalStormsKey = "LocalStorms"
let kNoStormsKey = "NoStorms"
let kMeteorologistKey = "MeteorologistAlerts"

/* NSNOTIFICATIONS CONSTANTS */
let kNotificationPush = "NotificationPush"

/* ALERT BAR CONTROLS */
let kNotificationBar = true
let kLiveStreamBar = true
let kNotificationKey = "NotificationKey"

/* HURRICANE DATE FORMAT */
let kDefaultDateFormat = "EEEE, dd MMM yyyy HH:mm:ss Z"

/* ANIMATION RELATED */
let kAnimationDuration = 1.0
let kNotificationBarAnimation = 0.3
let kImagesAnimationDuration = 0.5

/* GOOGLE ANALYTICS CONSTANTS */
let kNotification = "Notification"
let kStormCenter = "Storm Center"
let kTropicsWatch = "Tropics Now"
let kWatchesAndWarnings = "Watches & Warnings"
let kPlanAndPrepare = "Plan & Prepare"
let kMetUpdate = "Met Update"
let kLocalRadar = "Local Radar"
let kSetting = "Setting"
let kHeadlines = "Headlines"

let kTab = "Tab: %@"
let kStormID = "Storm ID: %@"

let kClicked = "Clicked"
let kAllowed = "Allowed"
let kRejected = "Rejected"
let kGPSShared = "GPS Shared"
let kMaps = "Maps"
let kZoomed = "Zoomed"
let kClosed = "Closed"
let kRotatedLandscape = "Rotated to Landscape"
let kRotatedPortrait = "Rotated to Portrait"

let kWeatherNews = "Weather News"
let kLiveMap = "Live Map"
let kStormTracker = "Tracker"
let kLandingPage = "Landing Page"
let kPushAlert = "Push Alert"
let kOpened = "Opened"
let kStationHeadlines = "Headlines"

/* HUD */
let kHUDLabelText = "Loading..."
let kHUDLabelFont = UIFont(name: kHurricaneFont_SemiBold, size: 15)

/* NAVIGATION BAR RELATED */
let kBackButtonTitle = ""

/* ERROR HANDLING */
let kOk = "OK"
let kRetry = "Retry"
let kCancel = "Cancel"
let kErrorTitle_NoInternet = "Network Error"
let kErrorMessage_NoInternet = "Please check your internet connection."

let kErrorTitle_NoData = "Data Unavailable"
let kErrorMessage_NoData = "Please try again later."

let kNoInternetStatusCode = 0
let kNoDataStatusCode = -1

let kAutoRefreshTimeInterval = 300
let kAnimationMovementSpeed = 0.65

let kViewBackgroundColor = UIColor(red: (5.0 / 255.0), green: (26.0 / 255.0), blue: (45.0 / 255.0), alpha: 1.0)
let kTopPadding: CGFloat = 30.0

/*SETTINGS PAGE RELATED */
let kSettingsStormsHeader = "Know When New Storm\nInformation is Available"
let kSettingsMetsUpdates = "Meteorologist Alerts"
let kSettingsStormsUpdates = "For All Active Storms"
let kSettingsLocalUpdates = "For Local Storms Only"
let kSettingsAllDisabled = "Turn Off Storm Updates"

/* REMOTE CONFIG KEYS */
let VAR_GA_TRACKING_ID = "SERVICES_GOOGLE_ANALYTICS_TAG"
let kAdMobUnitId = "ADS_TAG"
let kWeatherNewsURL = "FLAVOR_WEATHER_NEWS_URL"
let kPlanAndPrepareURL = "FLAVOR_PLAN_PREPARE_URL"
let kHurricanesAPIURL = "FLAVOR_HURRICANES_API_URL"
let kDefaultLat: String = "latitude"
let kDefaultLon = "longitude"
let kDefaultCoordinates = "FLAVOR_DEFAULT_COORDINATES"
let kSettingsMetsHeader = "FLAVOR_MET_BRAND_PUSH_ALERT_TITLE"
let kItunesAppId = "ITUNES_APP_ID"
let kAPIURL = "API_URL"
let kForecastVideoURL = "FLAVOR_VIDEO_FORECAST_URL"
let kLivestreamURL = "FLAVOR_LIVESTREAM_URL"
let kServiceSailthruAppKey = "SERVICES_SAILTHRU_APP_KEY"
let kStationHeadlinesURL = "FLAVOR_HEADLINES"
let kBraze = "FLAVOR_LIVESTREAM_URL"
let kBrazeApiKey = "BRAZE_API_KEY"
let kBrazeEndpoint = "BRAZE_ENDPOINT"

/* SDK Key for WSI SDK 2.15.0 */
let SDK_KEY = "7B4966DE-936F-4A88-BD45-95FDA697766F"

/* Carnival */
let kCarnivalChannelsSubscribed = "carnivalChannelsSubscribed"
let NotificationChannelsRegistered = "NotificationChannelsRegistered"
// wxworks data load notification
let kNotificationWXWorksDataLoad = "kNotificationWXWorksDataLoad"
let kiPadRatioForVideoDisplay = 0.5625
// sailthru notifications
let kNotificationSailthru = "kNotificationSailthru"
let kNotificationGoogleBannerADReset = "kNotificationGoogleBannerADReset"
let kStormTitle = "No active storms to report at the moment. Please visit the Tropics section for potential storm formations."
let kCustomAttributeName = "happ_push_subscriptions"

private var deviceToken: Data?
private var isNotificationPermissionGranted: Bool?

class AppDefaults: NSObject {
    
    @objc public class func getMoreTabStatus() -> Bool {
        return isMoreTabSelected
    }
    @objc public class func setMoreTabStatus(status : Bool) {
        isMoreTabSelected = status
    }
    @objc public class func getisChildViewAdded() -> Bool {
        return isChildViewAdded
    }
    @objc public class func setIsChildViewAdded(status : Bool) {
        isChildViewAdded = status
    }
    @objc public class func getSelectedIndex() -> Int {
        return SelectedIndex
    }
    @objc public class func setSelectedIndex(index : Int) {
        SelectedIndex = index
    }

    @objc public class func getBlueconicPropertyName() -> String? {
            let urlScheme = AppDefaults.getURLScheme()

            // handling prod apps scenario.
            if let urlScheme = urlScheme {
                return "att_\(urlScheme.lowercased())"
            }

            return ""
        }

    @objc public class func getURLScheme() -> String? {
        if Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") != nil {
            let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [AnyHashable]
            for urlType in urlTypes ?? [] {
                guard let urlType = urlType as? [AnyHashable: AnyObject] else {
                    continue
                }
                if urlType["CFBundleURLSchemes"] != nil && (urlType["CFBundleURLSchemes"]?.count ?? 0 > 0) {
                    let array: [String] = urlType["CFBundleURLSchemes"] as! [String]
                    return array[0]
                }
            }
        }
        return ""
    }
    class func colorWithHexValue(_ rgbValue: Int) -> UIColor {
        return UIColor(red: (CGFloat((rgbValue & 0xFF0000) >> 16)) / 255.0, green: (CGFloat((rgbValue & 0xFF00) >> 8)) / 255.0, blue: (CGFloat(rgbValue & 0xFF)) / 255.0, alpha: 1.0)
    }

    class func getHTMLStringFromString(_ inputString: String) -> String {
        let cssPath: String? = Bundle.main.path(forResource: "HTMLstyling", ofType: "css")
        if cssPath != nil {
            let cssURL: URL = URL(fileURLWithPath: cssPath!)
            let html: String = "<link rel='stylesheet' type='text/css' href='\(cssURL)'>\(inputString)"
            return html
        }
        return ""
    }

    class func hexStringToUIColor (_ hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: (CharacterSet.whitespacesAndNewlines as CharacterSet)).uppercased()

        if cString.hasPrefix("#") {
            let index = cString.index(cString.startIndex, offsetBy: 1)
            cString = String(cString.suffix(from: index))
        }

        if cString.count != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    class func getColorCodeForKey(_ key: String) -> AnyObject {
        let presentationDict: NSDictionary? = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "PRESENTATION")) as? NSDictionary
        if presentationDict != nil {
            let colorsDict: NSDictionary? = (presentationDict!.object(forKey: "COLORS")) as? NSDictionary
            if colorsDict != nil {
                let color = colorsDict!.object(forKey: key)
                if color != nil {
                    return color! as AnyObject
                }
            }
        }

        return "" as AnyObject
    }

    class func checkInternetConnection() -> Bool {
        let reachability: Reachability = Reachability.forInternetConnection()
        let networkStatus: NetworkStatus = reachability.currentReachabilityStatus()
        return !(networkStatus == NetworkStatus.NotReachable)
    }

    class func getAPIURL() -> String {
//        let dataAPIURL: String? = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kHurricanesAPIURL) as? String
        let dataAPIURL: String? = "https://weather.whizti.com/hurricane/WPLG.json.php"
        let appGroup: String? = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "FLAVOR_APP_GROUP") as? String
        if appGroup != nil {
            let defaults = UserDefaults(suiteName: appGroup!)
            if defaults != nil {
                defaults!.set(dataAPIURL, forKey: kAPIURL)
                defaults!.synchronize()
            }
        }

        return (dataAPIURL != nil) ? dataAPIURL! : ""
    }

    class func getFlavorsStationHeadlinesURL() -> String {

        let strStationHeadlinesUrl = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kStationHeadlinesURL)) as? String
        if strStationHeadlinesUrl != nil {
            return strStationHeadlinesUrl!
        }
        return ""
    }

    class func getForacstVideoURL() -> String {

        let strVideoUrl = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kForecastVideoURL)) as? String
        if strVideoUrl != nil {
            return strVideoUrl!
        }
        return ""
    }

    class func getLivestreamURL() -> String {

        let strLivesteamURL = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kLivestreamURL)) as? String
        if strLivesteamURL != nil {
            return strLivesteamURL!
        }
        return ""
    }
    
    class func getBrazeAPIKey() -> String {

        let strBrazeKey = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kBrazeApiKey)) as? String
        if strBrazeKey != nil {
            return strBrazeKey!
        }
        return ""
    }
    
    class func getBrazeEndpoint() -> String {

        let strBrazeEndpoint = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kBrazeEndpoint)) as? String
        if strBrazeEndpoint != nil {
            return strBrazeEndpoint!
        }
        return ""
    }

    class func getViewFrame(_ inputViewController: UIViewController) -> CGRect {
        let navigationBarHeight: CGFloat = inputViewController.navigationController!.navigationBar.frame.size.height
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarHeight
        var frame: CGRect = UIScreen.main.bounds
        frame.size.height -= navigationBarHeight + statusBarHeight
        return frame
    }

    class func getScreenSize() -> CGSize {
        return UIScreen.main.bounds.size
    }

    class func getC2Value() -> String {

        if let comscoreDict: [AnyHashable: Any] = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "SERVICES_COMSCORE") as? [AnyHashable: Any] {
            let c2Value: String? = comscoreDict["C2_VALUE"] as? String
            if c2Value != nil && c2Value!.count > 0 {
                return c2Value!
            }
        }
        return ""
    }
    
    class func getC4Value() -> String {

        if let comscoreDict: [AnyHashable: Any] = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "SERVICES_COMSCORE") as? [AnyHashable: Any] {
            let c4Value: String? = comscoreDict["C4_VALUE"] as? String
            if c4Value != nil && c4Value!.count > 0 {
                return c4Value!
            }
        }
        return ""
    }

    class func getPublisherSecretCode() -> String {

        if let comscoreDict: [AnyHashable: Any] = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "SERVICES_COMSCORE") as? [AnyHashable: Any] {
            let publisherCode: String? = comscoreDict["PUBLISHER_SECRET_CODE"] as? String
            if publisherCode != nil && publisherCode!.count > 0 {
                return publisherCode!
            }
        }

        return ""
    }

    class func getCarnivalAPPKey() -> String {

        let strLivesteamURL = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kServiceSailthruAppKey)) as? String
        if strLivesteamURL != nil {
            return strLivesteamURL!
        }

        return ""
    }

    class func registerChannels() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: kCarnivalChannelsSubscribed) {
            defaults.set(true, forKey: kCarnivalChannelsSubscribed)
        
            let channelArray = [kAllStormsChannel, kMetsUpdateChannel]
            
            AppDelegate.braze?.user.setCustomAttribute(key: kCustomAttributeName, array: channelArray)
    
            //print("Channels registered on Carnival")
            defaults.set(channelArray, forKey: kCustomAttributeName)
            defaults.synchronize()
            
        } else {
            let channels = defaults.value(forKey: kCustomAttributeName) as? [String]
            let channelsSailthruExistingUsers = defaults.value(forKey: "channels") as? [String]
            if channels != nil {

                AppDelegate.braze?.user.setCustomAttribute(key: kCustomAttributeName, array: channels!)
                
            } else if channelsSailthruExistingUsers != nil {
                // will register old sailthru users to braze users
               // print(channelsSailthruExistingUsers)
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
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: NotificationChannelsRegistered), object: nil, userInfo: nil)
    }

    class func getDeviceToken() -> Data? {
        return deviceToken
    }

    class func setDeviceToken(token: Data?) {
        deviceToken = token
    }
    
    class func setPushNotificationPermissionStatus(isPermission: Bool?) {
        isNotificationPermissionGranted = isPermission
    }
    
    class func getPushNotificationPermissionStatus() -> Bool? {
        return isNotificationPermissionGranted
    }

    class func getBottomPadding() -> CGFloat {
        let window = UIApplication.shared.keyWindow
        if window != nil {
            return (window?.safeAreaInsets.bottom) ?? 0
        }
        return 0.0
    }

    class func getMinimumUsageForRating() -> Int {

        let minimumUsage = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "FLAVOR_MINIMUM_USAGE_FOR_RATING_REQUEST")) as? NSString
        if minimumUsage == nil {
            return 6
        }
        return (minimumUsage!).integerValue
    }

    class func getWxWorksAPIKey() -> String {
        let strAPIKey = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "WSI_WXWORKS_KEY")) as? String
        if strAPIKey != nil {
            return strAPIKey!
        }
        return ""
    }

    class func getCustomViewFrame(viewFrame: inout CGRect) {
        let topPaddingInsets = getTopPadding()
        if topPaddingInsets > 0.0 {
            viewFrame.origin.y = viewFrame.origin.y + topPaddingInsets + kTopPadding/3
            viewFrame.size.height = viewFrame.size.height - (topPaddingInsets+kTopPadding/3)
        } else {
            viewFrame.origin.y = viewFrame.origin.y + kTopPadding
            viewFrame.size.height = viewFrame.size.height - kTopPadding
        }
    }

    class func getTopPadding() -> CGFloat {
        
        if #available(iOS 14.0, *) {
            let window = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .last { $0.isKeyWindow }
            if let topValue = window?.safeAreaInsets.top {
                return topValue
            } else {
                return 0.0
            }
            
        } else {
            return 0.0
        }
    }

    class func setNavigationBarTitle(_ title: String, _ view: UIView) {
        let headerLabel = UILabel(frame: CGRect(x: 0, y: UIApplication.shared.statusBarHeight, width: UIScreen.main.bounds.width, height: navigationBarHeight))
        headerLabel.backgroundColor = AppDefaults.colorWithHexValue(kWebViewControlsBgColor)
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont(name: kHurricaneFont_Bold, size: (IS_IPAD ? 29 : 24))
        headerLabel.textAlignment = .center
        headerLabel.text = title
        view.addSubview(headerLabel)
    }

    class func getUpdatedContent(_ content: String) -> String? {
        if content.contains("DT:") {
            let words = content.split(separator: " ")
            for word in words {
                if word.contains("DT:") {
                    let strTimestamp = (word.split(separator: ":")).last
                    if strTimestamp != nil {
                        let timestamp = Double(strTimestamp!)
                        if timestamp != nil {
                            let dateformat = DateFormatter()
                            dateformat.dateFormat = "h:mm a zzz"
                            let utc = NSDate(timeIntervalSince1970: timestamp!)
                            dateformat.timeZone = TimeZone.current
                            let localTime: String = dateformat.string(from: utc as Date)
                            print(localTime)
                            let stringToReplace = String(format: "DT:%@", strTimestamp! as CVarArg)
                            let newString = content.replacingOccurrences(of: stringToReplace, with: localTime, options: .literal, range: nil)
                            return newString
                        }
                    }
                }
            }
        }

        return content
    }
    // MARK: Header For WKWebView
    class func getHeaderForWKWebView() -> String? {
        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=0.0, maximum-scale=1.0, minimum-scale=0.0, user-scalable=no'></header>"
        return headerString
    }

    // MARK: Needs Update
    @objc public class func  getMinimumVersion() -> String? {
        let minSupportedVersion = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "APP_FORCE_VERSION")
         return minSupportedVersion as? String
    }

    @objc public class func needsUpdate() -> Bool {
         if let minSupportedVersion = AppDefaults.getMinimumVersion() {
            let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            if currentVersion?.compare(minSupportedVersion, options: .numeric, range: nil, locale: .current) == .orderedAscending {
                print(
                    "Exiting application. Version \(String(describing: currentVersion)). Minimum supported version is \(minSupportedVersion).")
                return true
            }
         }
         return false
    }

    @objc public class func getRadarLayers() -> [AnyObject] {
        if let radarLayer: [AnyObject] = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "WSI_LOCALRADAR_LAYERS") as? [AnyObject] {
            
            return radarLayer
        }
        return []
    }
    @objc public class func getBlueconicDialogStatus() -> Bool {
            let status = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "SERVICES_BLUECONIC_ATT_DIALOG_ENABLED") as? Bool ?? false
            print(status)
            return status
    }
    
    class func hideTabbar() {
        if let tabCtrl = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            tabCtrl.tabBar.isHidden = true
            tabCtrl.setTabBarVisible(visible: false, duration: 0.0, animated: false)
        }
    }
    
    class func showTabbar() {
        if let tabCtrl = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            tabCtrl.tabBar.isHidden = false
            tabCtrl.setTabBarVisible(visible: true, duration: 0.0, animated: false)
        }
    }
    
    @objc public class func customSnapshotFromView(inputView:UIView) -> UIView? {
        
        return autoreleasepool { (() -> UIView).self
            let layer = UIApplication.shared.keyWindow!.layer
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
            guard let context = UIGraphicsGetCurrentContext() else {return nil}
            layer.render(in:context)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            let snapshotView = UIImageView(image: newImage)
            return snapshotView
        }
        
    }
    class func getMoreSettingConfig() -> [Any] {

        let settingsConfig = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "FLAVOR_MORE_MENU")) as? [Any]
        if settingsConfig != nil {
            return settingsConfig!
        }
        return []
    }

}

extension UIApplication {
    var statusBarHeight: CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        return statusBarHeight
    }
}
