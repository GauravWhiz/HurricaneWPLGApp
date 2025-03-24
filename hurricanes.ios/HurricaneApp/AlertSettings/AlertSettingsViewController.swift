//
//  AlertSettingsViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 14/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation
import MessageUI

class AlertSettingsViewController: UIViewController, RadioButtonDelegate, AdMobViewControllerDelegate, UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate {
    let kCellColor = 0x143146
    let kSettingsHeaderLabelFontSize = (IS_IPAD ? 40 : 20.2)
    let kSettingsRowTextFontSize = (IS_IPAD ? 36 : 18.11)
    let kSettingTableHeaderHeight = (IS_IPAD ? 160 : 99)
    private let kSettingsAppVersionFontSize = (IS_IPAD ? 30 : 14)
    
    let kOnImage = "toggleOn.png"
    let kOffImage = "toggleOff.png"
    let kFirstGroupNotificationID = "FirstGroupNotificationID"
    let kErrorTitle = "Notification Settings"
    let kErrorMessage = "Error while fetching Channels Data"

    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var table: UITableView!
    var channelArray = [String]()
    var isLandscapeRequired: Bool = false
    var selectedButton: String = ""
    var isSaveInProgress: Bool = false
    private var topNavView:UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        AppDefaults.setNavigationBarTitle("Settings", self.view)
        self.table!.delegate = self
        self.table!.dataSource = self
        self.view.frame = UIScreen.main.bounds
        self.table.backgroundView = nil
        self.view.backgroundColor = AppDefaults.colorWithHexValue(Int(kBackgroundColor))
        self.table.backgroundColor = AppDefaults.colorWithHexValue(Int(kBackgroundColor))
        let defaults = UserDefaults.standard
        let channels = defaults.value(forKey: kCustomAttributeName) as? [String]
        if channels != nil {
            self.channelArray = channels!
        }
        
        self.topNavView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: kTopPadding))
        self.topNavView.backgroundColor = AppDefaults.colorWithHexValue(Int(kBackgroundColor))
        self.view.addSubview(self.topNavView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var frame: CGRect = self.table.frame
        frame.size.height = self.view.frame.size.height
        self.table.frame = frame
        let adUnitId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kAdMobUnitId) as? String
        if adUnitId != nil {
            self.showAdMobBannerWithAdUnitID(adUnitId!)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationChannelsRegistered), name: NSNotification.Name(rawValue: NotificationChannelsRegistered), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BlueconicHelper.createBlueconicEvent(self, forPageView: "Main/AlertSettingsViewController")
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationChannelsRegistered), object: nil)
        super.viewWillDisappear(animated)
    }

    func showAdMobBannerWithAdUnitID(_ adUnitId: String) {
        let adMobViewController: AdMobViewController = AdMobViewController(nibName: "AdMobViewController", bundle: nil)
        adMobViewController.delegate = self
        self.view?.addSubview(adMobViewController.view)
        adMobViewController.loadAdMobBannerToClass(self, adUnitID: adUnitId)
    }

    func didSuccessToReceiveAd() {
        var frame: CGRect = self.table.frame
        frame.size.height = frame.size.height - (CGFloat(kAdMobAdHeight)+AppDefaults.getBottomPadding())
        self.table.frame = frame
    }
    
    func didSuccessToReceiveAd(ADHeight:CGFloat) {
        var frame: CGRect = self.table.frame
        frame.size.height = frame.size.height - (CGFloat(ADHeight)+AppDefaults.getBottomPadding())
        self.table.frame = frame
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

    // MARK: UITableViewDataSource Methods

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 2 || section == 3 {
            // app version or app support team
            return 0
        } else {
            let headerLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            if IS_IPAD {
                headerLabel.frame = CGRect(x: 11, y: 20, width: 684, height: 150)
            } else {
                headerLabel.frame = CGRect(x: 11, y: 20, width: tableView.frame.size.width - 20, height: 60)
            }
            headerLabel.numberOfLines = 2
            headerLabel.font = UIFont(name: kHurricaneFont_Medium, size: CGFloat(kSettingsHeaderLabelFontSize))
            switch section {
            case 0:
                var vl = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kSettingsMetsHeader) as? String
                vl = vl!.replacingOccurrences(of: "\\n", with: "")
                headerLabel.text = kSettingsStormsHeader
            case 1:
                headerLabel.text = kSettingsStormsHeader
            default:
                headerLabel.text = nil
            }

            headerLabel.sizeToFit()
            return headerLabel.frame.origin.y + headerLabel.frame.size.height + 20
        }
        
        
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return (IS_IPAD ? 20 : 10)
        } else if section == 2 || section == 3 {
            return 0
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 2 || section == 3 {
            // app version or app support team
            return nil
        } else {
            let headerView: UIView = UIView()
            let headerLabel: UILabel = UILabel()
            let label: UILabel = UILabel()
            if IS_IPAD {
                headerView.frame = CGRect(x: 0, y: 0, width: 704, height: 180)
                headerLabel.frame = CGRect(x: 11, y: 20, width: 684, height: 100)
                label.frame = CGRect(x: 0, y: 140, width: 704, height: 1)
            } else {
                headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 99)
                headerLabel.frame = CGRect(x: 11, y: 20, width: tableView.frame.size.width - 20, height: 60)
                label.frame = CGRect(x: 0, y: 82, width: tableView.frame.size.width, height: 1)
            }
            headerLabel.numberOfLines = 0
            headerLabel.backgroundColor = AppDefaults.colorWithHexValue(kBackgroundColor)
            headerLabel.textColor = UIColor.white
            headerLabel.font = UIFont(name: kHurricaneFont_Medium, size: CGFloat(kSettingsHeaderLabelFontSize))
            switch section {
            case 0:

                var vl = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kSettingsMetsHeader) as? String)!
                vl = vl.replacingOccurrences(of: "\\n", with: "")
                headerLabel.text = vl
            case 1:
                headerLabel.text = kSettingsStormsHeader
            default:
                headerLabel.text = nil
            }

            headerLabel.sizeToFit()
            var frame: CGRect = headerView.frame
            frame.size.height = headerLabel.frame.origin.y + headerLabel.frame.size.height + 25
            headerView.frame = frame
            headerView.addSubview(headerLabel)
            frame = label.frame
            frame.origin.y = headerLabel.frame.origin.y + headerLabel.frame.size.height
            label.frame = frame
            label.backgroundColor = AppDefaults.colorWithHexValue(kLabelGreenColorDark)
            headerView.addSubview(label)
            return headerView
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return (IS_IPAD ? 92 : 46)
        } else if (indexPath as NSIndexPath).section == 2 {
            // app version
            return (IS_IPAD ? 100 : 50)
        } else {
            return (IS_IPAD ? 102 : 51)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 2 {
            // For app supporrt team
            let CellIdentifier: String = "CellAppSupport"
            var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
                cell!.backgroundColor = AppDefaults.colorWithHexValue(kCellColor)
                cell!.textLabel?.textColor = UIColor.white
                cell!.textLabel?.font = UIFont(name: kHurricaneFont_Regular, size: CGFloat(kSettingsRowTextFontSize))
//                cell!.accessoryType = .disclosureIndicator
//                cell!.tintColor = UIColor.white
                let chevron = UIImage(named: "rightArrow.png")
                cell!.accessoryType = .disclosureIndicator
                cell!.accessoryView = UIImageView(image: chevron!)
                
                let clickButton: UIButton = UIButton(type: .custom)
                clickButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: (cell?.frame.size.height)!)
               
                clickButton.adjustsImageWhenHighlighted = false
                clickButton.addTarget(self, action: #selector(self.onAppSupportClick(_:)), for: .touchDown)
                cell?.addSubview(clickButton)
            }
            
            cell!.textLabel!.text = "Contact App Support Team"

            return cell!
        } else if indexPath.section == 3 {
            // For app version
            let CellIdentifier: String = "CellAppVersion"
            var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
                cell?.backgroundColor = UIColor.clear
                
                var titleLabelHeight:CGFloat!
                var subTitleLabelHeight:CGFloat!
                
                if IS_IPAD {
                    titleLabelHeight = 32
                    subTitleLabelHeight = 32
                } else {
                    titleLabelHeight = 16
                    subTitleLabelHeight = 20
                }
                
                let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: titleLabelHeight))
                titleLabel.textColor = UIColor.white
                titleLabel.textAlignment = .center
                titleLabel.backgroundColor = UIColor.clear
                titleLabel.font = UIFont(name: kHurricaneFont_Italic, size: CGFloat(kSettingsAppVersionFontSize))
                cell?.addSubview(titleLabel)
                
                let appBundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
                
                if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    titleLabel.text = "v\(appVersion)(\(appBundleVersion!))"
                } else {
                    cell?.isHidden = true
                }
                
                let detailedLabel = UILabel(frame: CGRect(x: 0, y: titleLabelHeight, width: UIScreen.main.bounds.width, height: subTitleLabelHeight))
                detailedLabel.textColor = UIColor.white
                detailedLabel.textAlignment = .center
                detailedLabel.font = UIFont(name: kHurricaneFont_Italic, size: CGFloat(kSettingsAppVersionFontSize))
                cell?.addSubview(detailedLabel)
                detailedLabel.text = ""
                
            }
            
            return cell!
        } else {
            let CellIdentifier: String = "Cell"
            var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
                cell!.backgroundColor = AppDefaults.colorWithHexValue(kCellColor)
                cell!.textLabel?.textColor = UIColor.white
                cell!.textLabel?.font = UIFont(name: kHurricaneFont_Regular, size: CGFloat(kSettingsRowTextFontSize))
            }
            if (indexPath as NSIndexPath).section == 0 {
                let toggleButton: UIButton = UIButton(type: .custom)
                if IS_IPAD {
                    toggleButton.frame = CGRect(x: 0, y: 0, width: 166, height: 80)
                } else {
                    toggleButton.frame = CGRect(x: 0, y: 0, width: 83, height: 40)
                }
                toggleButton.adjustsImageWhenHighlighted = false
                toggleButton.addTarget(self, action: #selector(AlertSettingsViewController.onClickToggle(_:)), for: .touchDown)
                toggleButton.setImage(UIImage(named: kOffImage), for: UIControl.State())
                toggleButton.setImage(UIImage(named: kOnImage), for: .selected)
                self.setButtonSelection(toggleButton)
                cell!.accessoryView = toggleButton
            }
            if (indexPath as NSIndexPath).section == 1 {
                let accessoryButton: RadioButton = RadioButton(groupId: kFirstGroupNotificationID, index: (indexPath as NSIndexPath).row)
                self.setUserSettings(accessoryButton)
                cell!.accessoryView = accessoryButton
                RadioButton.addObserverForGroupId(kFirstGroupNotificationID, observer: self)
                let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AlertSettingsViewController.handleCellTap(_:)))
                tapRecognizer.numberOfTapsRequired = 1
                cell!.addGestureRecognizer(tapRecognizer)
            }
            switch (indexPath as NSIndexPath).section {
            case 0:
                cell!.textLabel!.text = kSettingsMetsUpdates
            case 1:
                switch (indexPath as NSIndexPath).row {
                case 0:
                    cell!.textLabel!.text = kSettingsStormsUpdates
                case 1:
                    cell!.textLabel!.text = kSettingsLocalUpdates
                case 2:
                    cell!.textLabel!.text = kSettingsAllDisabled
                case 3:
                    cell!.textLabel!.text = "Test"
                default:
                    break
                }

            default:
                break
            }

            return cell!
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            // For app supporrt team
            self.sendMail()
        }
    }
    
    private func sendMail() {
        
        if AppDefaults.checkInternetConnection() {
            if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["webcontent@wplg.com"])
                
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
                let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
                
                let subject = appName + " v" + version + "(\(bundleVersion))"
                    mail.setSubject(subject)
                
                mail.setMessageBody(self.getMessageBody(), isHTML: true)

                    present(mail, animated: true)
            } else {
                // show failure alert
                self.showAlert("Account Required", message: "Mail account required")
            }
        } else {
            self.showAlert("No Internet Connection", message: "Please check your settings.")
        }
        
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
    }
    
    private func getMessageBody() -> String {
        let helpMessage = "</br></br></br></br></br>------</br></br>To help us diagnose and solve user-reported issues, we've automatically inserted the technical information found below.</br></br>"
        let deviceToken = AppDefaults.getDeviceToken()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        let deviceModel = UIDevice.modelName
        let strNotificationStatus = AppDefaults.getPushNotificationPermissionStatus()! ? "On":"Off"
        let channelsInString = self.channelArray.joined(separator: ", ")
        var deviceTokenString = deviceToken?.hexString
        
        if deviceTokenString == nil {
            deviceTokenString = "Not found"
        }
        
        let msgBody = "\(helpMessage)" + "<b>Version:</b>&nbsp" + "\(appVersion)(\(bundleVersion))" + "</br> <b>Device:</b>&nbsp \(deviceModel), iOS \(UIDevice.current.systemVersion)</br>" + "<b>Anonymous ID:</b>&nbsp " + "\(UIDevice.current.identifierForVendor?.uuidString ?? "Not found")</br>" + "<b>Push Token:</b> \(deviceTokenString ?? "Not found") </br>" + "<b>Push Alert Access:</b>&nbsp" + "\(strNotificationStatus)</br>" + "<b>Location Access:</b>&nbsp" + "\(CoreLocationManager.sharedInstance.fetchLocationAuthorizationStatus())</br>" + "<b>Channels:</b>&nbsp" + "\(channelsInString)"
        return msgBody
    }
    
    func showAlert(_ title: String, message: String) {
        let strContent = AppDefaults.getUpdatedContent(message)
        let alert = UIAlertController(title: title, message: strContent, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            _ in

        }
       
        // Add the actions
        alert.addAction(okAction)
        
        let windowOfApp = UIApplication.shared.keyWindow
        if (windowOfApp!.rootViewController) != nil &&
            (windowOfApp!.rootViewController!.isKind(of: UINavigationController.self)) {
            let presentedViewController = (windowOfApp!.rootViewController as! UINavigationController).viewControllers.last! as UIViewController
            presentedViewController.present(alert, animated: true, completion: nil)
        } else if (windowOfApp!.rootViewController) != nil &&
            (windowOfApp!.rootViewController!.isKind(of: UITabBarController.self)) {
            
            let selectedNavController = (windowOfApp!.rootViewController as! UITabBarController).selectedViewController
            if selectedNavController != nil {
                let presentedViewController = (selectedNavController as! UINavigationController).viewControllers.last! as UIViewController
                presentedViewController.present(alert, animated: true, completion: nil)
            }
        }
        
    }

    @objc func handleCellTap(_ gesture: UITapGestureRecognizer) {
        if AppDefaults.checkInternetConnection() {   // HAPP-549
            let cell: UITableViewCell? = (gesture.view as? UITableViewCell)
            if cell != nil {
                let tappedIndexPath: IndexPath? = self.table.indexPath(for: cell!)
                if tappedIndexPath != nil {
                    let accessoryButton: RadioButton = RadioButton(groupId: kFirstGroupNotificationID, index: (tappedIndexPath! as NSIndexPath).row)
                    cell!.accessoryView = accessoryButton
                    accessoryButton.handleButtonTap(accessoryButton)
                }
            }
        } else {
            self.handleNetworkError(nil, statusCode: NSURLErrorNotConnectedToInternet)
        }
    }

    @objc func onClickToggle(_ sender: UIButton) {
        if AppDefaults.checkInternetConnection() { // HAPP-549
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                self.setMeteorologistEnabled()
            } else {
                self.setMeteorologistDisabled()
            }
        } else {
            self.handleNetworkError(nil, statusCode: NSURLErrorNotConnectedToInternet)
        }
    }
    
    @objc func onAppSupportClick(_ sender: UIButton) {
        self.sendMail()
    }

    func setUserSettings(_ accessoryButton: RadioButton) {
        switch accessoryButton.index {
        case 0:
            if self.channelArray.contains(kAllStormsChannel) {
                accessoryButton.button.isSelected = true
            }
        case 1:
            if self.channelArray.contains(kLocalStormsChannel) {
                accessoryButton.button.isSelected = true
            }
        case 2:
            if !self.channelArray.contains(kAllStormsChannel) && !self.channelArray.contains(kLocalStormsChannel) {
                accessoryButton.button.isSelected = true
            }
        default:
            break
        }
    }

    func setButtonSelection(_ accessoryButton: UIButton) {
        if self.channelArray.contains(kMetsUpdateChannel) {
            accessoryButton.isSelected = true
        }
    }

    // MARK: RadioButtonDelegate method

    func radioButtonSelected(_ index: Int, groupId: String) {
        if AppDefaults.checkInternetConnection() {  // HAPP-549
            switch index {
            case 0:
                self.selectedButton = kAllStormsChannel
                if !self.channelArray.contains(kAllStormsChannel) {
                    self.channelArray.append(kAllStormsChannel)
                }
                if let index = self.channelArray.firstIndex(of: kLocalStormsChannel) {
                    self.channelArray.remove(at: index)
                }

            case 1:
                self.selectedButton = kLocalStormsChannel
                if !self.channelArray.contains(kLocalStormsChannel) {
                    self.channelArray.append(kLocalStormsChannel)
                }
                if let index = self.channelArray.firstIndex(of: kAllStormsChannel) {
                    self.channelArray.remove(at: index)
                }

            case 2:
                self.selectedButton = ""
                if let indexAll = self.channelArray.firstIndex(of: kAllStormsChannel) {
                    self.channelArray.remove(at: indexAll)
                }
                if let indexLocal = self.channelArray.firstIndex(of: kLocalStormsChannel) {
                    self.channelArray.remove(at: indexLocal)
                }

            default:
                break
            }

            self.updateChannelsonCarnival()
        } else {
            self.handleNetworkError(nil, statusCode: NSURLErrorNotConnectedToInternet)
        }
    }

    func updateChannelsonCarnival() {
        let defaults = UserDefaults.standard
        AppDelegate.braze?.user.setCustomAttribute(key: kCustomAttributeName, array: self.channelArray)

        print("Channels registered on Carnival")
        defaults.set(self.channelArray, forKey: kCustomAttributeName)
        defaults.synchronize()
        
    }

    func setMeteorologistEnabled() {
        if !self.channelArray.contains(kMetsUpdateChannel) {
            self.channelArray.append(kMetsUpdateChannel)
        }
        self.updateChannelsonCarnival()
    }

    func setMeteorologistDisabled() {
        if let index = self.channelArray.firstIndex(of: kMetsUpdateChannel) {
            self.channelArray.remove(at: index)
        }
        self.updateChannelsonCarnival()
    }

    @objc func notificationChannelsRegistered() {
        let defaults = UserDefaults.standard
        let channels = defaults.value(forKey: kCustomAttributeName) as? [String]
        if channels != nil {
            self.channelArray = channels!
        }
        self.table.reloadData()
    }
}

public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPhone14,7":                                    return "iPhone 14"
            case "iPhone14,8":                                    return "iPhone 14 Plus"
            case "iPhone15,2":                                    return "iPhone 14 Pro"
            case "iPhone15,3":                                    return "iPhone 14 Pro Max"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}
