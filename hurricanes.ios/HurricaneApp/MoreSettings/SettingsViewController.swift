//
//  SettingsViewController.swift
//  Hurricane
//
//  Created by APPLE on 06/02/23.
//  Copyright © 2023 PNSDigital. All rights reserved.
//
var moreSettingsSelectedIndexPath = IndexPath()
import UIKit

class SettingsViewController: UIViewController,SettingsProtocol {
    var moreSettingViewController:MoreSettingsViewController?
    var backgroundView = UIView()
    var ismenuOpen = Bool()
    var planAndPrepareViewControllerObj:PlanAndPrepareViewController?
    var weatherNewsViewControllerObj:WeatherNewsViewController?
    var watchAndWarningViewControllerObj:WatchAndWarningViewController?
    var alertSettingsViewControllerObj:AlertSettingsViewController?
    var liveMapViewControllerObj:LiveMapViewController?
    var headlinesViewControllerObj:HeadlinesListViewController?
    var downloadAppViewControllerObj:DownloadAppViewController?
    var settingsConfing = [Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsConfing = AppDefaults.getMoreSettingConfig()
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.height))
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.5
        self.view .addSubview(backgroundView)
        self.navigationController?.navigationBar.layer.zPosition = -1
        self.moreSettingViewController = MoreSettingsViewController()
        self.addChild(moreSettingViewController!)
        self.moreSettingViewController!.settingsProtocolObj = self
        var  frame = self.view.frame
        frame.origin.y = frame.size.height
        moreSettingViewController!.view.frame = frame
        self.view.addSubview(moreSettingViewController!.view)
        self.view.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
    }

    func showMenuView() {
        self.navigationController?.navigationBar.layer.zPosition = -1
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
            if(moreSettingsSelectedIndexPath.count != 0) {
                self.moreSettingViewController!.table.selectRow(at: moreSettingsSelectedIndexPath, animated: true, scrollPosition: .none)
            }
            self.view.bringSubviewToFront(self.moreSettingViewController!.view)
            var frame = self.view.frame
            frame.origin.y = 0
            self.moreSettingViewController!.view.frame = frame
            self.moreSettingViewController!.table.reloadData()
        }, completion: { (_) -> Void in
            self.ismenuOpen = true
        })
    }

    func closeMenuView() {
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
            self.view.bringSubviewToFront(self.moreSettingViewController!.view)
            var frame = self.view.frame
            frame.origin.y = frame.size.height
            self.moreSettingViewController!.view.frame = frame
            
        }, completion: { (_) -> Void in
            self.ismenuOpen = false
            self.navigationController?.navigationBar.layer.zPosition = 0
        })
    }
    func RemoveChildView() {
        
        self.planAndPrepareViewControllerObj?.willMove(toParent: nil)
        self.planAndPrepareViewControllerObj?.view.removeFromSuperview()
        self.planAndPrepareViewControllerObj?.removeFromParent()
        
        self.weatherNewsViewControllerObj?.willMove(toParent: nil)
        self.weatherNewsViewControllerObj?.view.removeFromSuperview()
        self.weatherNewsViewControllerObj?.removeFromParent()
        
        self.watchAndWarningViewControllerObj?.willMove(toParent: nil)
        self.watchAndWarningViewControllerObj?.view.removeFromSuperview()
        self.watchAndWarningViewControllerObj?.removeFromParent()
        
        self.alertSettingsViewControllerObj?.willMove(toParent: nil)
        self.alertSettingsViewControllerObj?.view.removeFromSuperview()
        self.alertSettingsViewControllerObj?.removeFromParent()
        
        self.liveMapViewControllerObj?.willMove(toParent: nil)
        self.liveMapViewControllerObj?.view.removeFromSuperview()
        self.liveMapViewControllerObj?.removeFromParent()
        
        self.headlinesViewControllerObj?.willMove(toParent: nil)
        self.headlinesViewControllerObj?.view.removeFromSuperview()
        self.headlinesViewControllerObj?.removeFromParent()
    }
    func OpenSettings(configData: [String : Any], selectedIndex : IndexPath) {
        
        if(configData["screen"]as? String ?? "" == "AppLink") {
            let data : [String : String] = configData["data"] as! [String : String]
            let app = UIApplication .shared
            let appPath : String = data["appSchema"] ?? ""
            let url  = URL(string: appPath)
            if(app.canOpenURL(url!)) {
                 app.open(url!)
            } else {
                AppDefaults.setIsChildViewAdded(status: true)
                moreSettingsSelectedIndexPath = selectedIndex
                self.closeMenuView()
                self.RemoveChildView()
                self.navigationController?.navigationBar.layer.zPosition = 0
            }
        } else {
            AppDefaults.setIsChildViewAdded(status: true)
            moreSettingsSelectedIndexPath = selectedIndex
            self.closeMenuView()
            self.RemoveChildView()
            self.navigationController?.navigationBar.layer.zPosition = 0
        }
        let frame = self.view.frame
       switch(configData["screen"] as! String) {
           
       case "PlanAndPrepare":
           self.planAndPrepareViewControllerObj = PlanAndPrepareViewController(nibName: "PlanAndPrepareViewController", bundle: nil)
           self.planAndPrepareViewControllerObj!.planAndPrepareUrl = configData["url"] as? String ?? ""
            self.planAndPrepareViewControllerObj!.view.frame = frame
           self.addChild(planAndPrepareViewControllerObj!)
           self.view.addSubview(planAndPrepareViewControllerObj!.view)
           self.view.bringSubviewToFront(planAndPrepareViewControllerObj!.view)
       case "WeatherNews":
            self.weatherNewsViewControllerObj = WeatherNewsViewController(nibName: "WeatherNewsViewController", bundle: nil)
           self.weatherNewsViewControllerObj!.weatherNewsUrl = configData["url"] as? String ?? ""
           self.weatherNewsViewControllerObj!.view.frame = frame
           self.addChild(weatherNewsViewControllerObj!)
           self.view.addSubview(weatherNewsViewControllerObj!.view)
           self.view.bringSubviewToFront(weatherNewsViewControllerObj!.view)
       case "WatchesAndWarnings":
           self.watchAndWarningViewControllerObj = WatchAndWarningViewController(nibName: "WatchAndWarningViewController", bundle: nil)
           self.watchAndWarningViewControllerObj!.isWatchesAndWarnings = true
           self.watchAndWarningViewControllerObj!.view.frame = frame
           self.addChild(watchAndWarningViewControllerObj!)
           self.view.addSubview(watchAndWarningViewControllerObj!.view)
           self.view.bringSubviewToFront(watchAndWarningViewControllerObj!.view)
       case "Radar":
           self.liveMapViewControllerObj = LiveMapViewController(nibName: "LiveMapViewController", bundle: nil)
           self.liveMapViewControllerObj?.isLocalRadar = true
           self.liveMapViewControllerObj?.view.frame = frame
           self.addChild(self.liveMapViewControllerObj!)
           self.view.addSubview(self.liveMapViewControllerObj!.view)
           self.view.bringSubviewToFront(self.liveMapViewControllerObj!.view)
       case "Headlines":
           self.headlinesViewControllerObj = HeadlinesListViewController(nibName: "HeadlinesListViewController", bundle: nil)
           self.headlinesViewControllerObj!.view.frame = frame
           self.addChild(self.headlinesViewControllerObj!)
           self.view.addSubview(self.headlinesViewControllerObj!.view)
           self.view.bringSubviewToFront(self.headlinesViewControllerObj!.view)
       case "Pins":
           let stormPinsUrl : String = configData["url"] as? String ?? ""
           if(stormPinsUrl != "") {
               if let url = URL(string: stormPinsUrl) {
                   UIApplication.shared.open(url, completionHandler: { (_) in
                       self.tabBarController?.selectedIndex = 0
                   })
               }
           }
       case "AppLink":
           let data : [String : String] = configData["data"] as! [String : String]
           let app = UIApplication .shared
           let appPath : String = data["appSchema"] ?? ""
           let url  = URL(string: appPath)
           if(app.canOpenURL(url!)) {
                app.open(url!)
           } else {
               self.downloadAppViewControllerObj = DownloadAppViewController(nibName: "DownloadAppViewController", bundle: nil)
               self.downloadAppViewControllerObj!.dataDict = configData
               self.downloadAppViewControllerObj!.view.frame = frame
               self.addChild(downloadAppViewControllerObj!)
               self.view.addSubview(downloadAppViewControllerObj!.view)
               self.view.bringSubviewToFront(downloadAppViewControllerObj!.view)
           }
           
       default:
           self.alertSettingsViewControllerObj = AlertSettingsViewController(nibName: "AlertSettingsViewController", bundle: nil)
           self.alertSettingsViewControllerObj!.view.frame = frame
           self.addChild(alertSettingsViewControllerObj!)
           self.view.addSubview(alertSettingsViewControllerObj!.view)
           self.view.bringSubviewToFront(alertSettingsViewControllerObj!.view)
       }

    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return [.portrait, .portraitUpsideDown]
    }
}
