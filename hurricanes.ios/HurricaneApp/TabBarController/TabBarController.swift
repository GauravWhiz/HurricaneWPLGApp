//
//  TabBarController.swift
//  KPRC
//
//  Created by APPLE on 30/12/22.
//  Copyright © 2022 PNSDigital. All rights reserved.
//
let tabbarSelectedItemColor = UIColor.init(ciColor: CIColor(red: 229/255.0, green: 103/255.0, blue: 66/255.0))
let tabBarBackgroundColor = UIColor.init(ciColor: CIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0))
import Foundation

class TabBarController : UITabBarController, DataDownloadManagerDelegate {
    
    var userInfoDictionary: [AnyHashable: Any]?
    var notificationOldID: String?
    var liveStreamViewController: LiveStreamViewController?
    var alertBarViewController: AlertBarViewController!
    var isPushReceived = false
    
    override func viewDidLoad() {
        self.tabBar.backgroundColor = tabBarBackgroundColor
        self.tabBar.barTintColor = tabBarBackgroundColor
        self.tabBar.tintColor = tabbarSelectedItemColor
        self.tabBar.unselectedItemTintColor = UIColor.darkGray
        self.tabBar.isTranslucent = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushNotificationReceived), name: NSNotification.Name(rawValue: kNotificationPush), object: nil)
    }
    
    func didSuccess(toSaveData isSuccess: Bool) {
        self.view.alpha = 1.0
        MBProgressHUD.hide(for: self.view.window, animated: true)
        
        self.pushOnNotification()
        self.showLiveStreamBar()
    }
    
    @objc func pushNotificationReceived(_ notificationObject: Foundation.Notification) {
        self.userInfoDictionary = (notificationObject as NSNotification).userInfo
        self.downloadAllData()
        self.isPushReceived = true
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kNotificationSailthru), object: nil, userInfo: nil)
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
         
            if let screenName = self.userInfoDictionary![kOpenScreenKey] as? String {
                self.pushScreenForId(screenName)
            }
        }
        self.userInfoDictionary = nil
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
    
    func pushNotificationsForId(_ idx: String) {
        if self.alertBarViewController == nil {
            self.alertBarViewController = AlertBarViewController(nibName: "AlertBarViewController", bundle: nil)
        }
        self.alertBarViewController.currentNavController = self.getCurrentNavigationController()

        self.alertBarViewController.notification = DataDownloadManager.sharedInstance.getDataForEntity(kEntityNotifications, id: idx)?.last as? Notification
        self.alertBarViewController.pushOnNotification()
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
        if stormCenterViewController.stormCenterDetailArray?.count ?? 0 > 0 {
            let nav = self.getCurrentNavigationController()
            
            let presentedViewController = (nav?.viewControllers.last! ?? stormCenterViewController) as UIViewController
            
            if let firstVC =  presentedViewController as? LandingPageViewController {
                firstVC.isPushReceived = true
            }
            
            stormCenterViewController.needsStormsDataWithStormId = stormId
            nav?.pushViewController(stormCenterViewController, animated: true)
        } else {
            let alertController = UIAlertController(title: kErrorTitle_NoData, message: "No Storm Exists", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: kOk, style: UIAlertAction.Style.default) { (_: UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getCurrentNavigationController() -> UINavigationController? {
        let selectedNavController = self.selectedViewController
        if selectedNavController != nil {
            return selectedNavController as? UINavigationController
        } else {
            return nil
        }
    }
    
    func pushToInformationNotAvailable() {
        let infoNotAvailableViewController = InfoNotAvailableViewController(nibName: "InfoNotAvailableViewController", bundle: nil)
        self.navigationController?.pushViewController(infoNotAvailableViewController, animated: true)
    }
    
    func downloadAllData() {
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
            self.view.addSubview(self.liveStreamViewController!.view)
        }
        self.liveStreamViewController!.liveStream = liveStreamArray!.last as? LiveStream
    }
    
    func setPushGANTrackEventWithLabel(_ label: String) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        let params = GAIDictionaryBuilder.createEvent(withCategory: kPushAlert, action: kOpened, label: nil, value: nil).build()as [NSObject: AnyObject]
        tracker.send(params)
    }
}

extension UITabBarController {
    func setTabBarVisible(visible:Bool, duration: TimeInterval, animated:Bool) {
        if (tabBarIsVisible() == visible) { return }
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)

        // animation
        UIViewPropertyAnimator(duration: duration, curve: .linear) {
            self.tabBar.frame.offsetBy(dx:0, dy:offsetY)
            self.view.frame = CGRect(x:0,y:0,width: self.view.frame.width, height: self.view.frame.height + offsetY)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }.startAnimation()
    }

    func tabBarIsVisible() -> Bool {
        return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
    }
}
