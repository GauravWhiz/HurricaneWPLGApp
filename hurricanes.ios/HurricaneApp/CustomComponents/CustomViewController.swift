//
//  CustomViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 28/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//
import MapKit

import Foundation
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

protocol CustomViewControllerDelegate: AnyObject {
    func imageViewDidDisplay()
    func imageViewDidClose()
    func adViewDidPresentScreen()
    func adViewDidDismissScreen()
    func setNavigationTitle(pTitle:String)
}

class CustomViewController: GAITrackedViewController, MBProgressHUDDelegate, ImageViewControllerDelegate, DataDownloadManagerDelegate, AdMobViewControllerDelegate, HurricaneCellDelegate, ErrorHandler, UITableViewDelegate, UITableViewDataSource {
    var stormCenterDetailArray: [AnyObject]?
    weak var delegate: CustomViewControllerDelegate?
    @IBOutlet weak var customTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subHeaderLabel: UILabel!

    var currentIdx: String?
    var rightBarButtonItem: UIButton?
    var imageNameWithPathArray: [AnyObject]?
    var isWebViewLoaded: Bool = false
    var imageViewController: ImageViewController?
    var webViewHeight: CGFloat = 0.0
    var maxMap: MaxMapViewController = MaxMapViewController.sharedInstance
    var timer: Timer?
    var displayMap: Bool = false
    var showMapFullScreen: Bool = false
    var mapDict: [String: Any]?
    var tapOnImage: UITapGestureRecognizer?
    var isStatusBarHidden = false
    var isTropicsWatch: Bool = false
    var isWatchesAndWarnings: Bool = false
    private var isImageViewDidClose = false
    var needsStormsDataWithStormId:String?
    private var isAdReceived = false

    private var stormSurgeTitle = "Storm Surge Forecast"
    private var isStormSurgeFound = false
    private var stormSurgeURL = ""
    
    private var loop_gif: String?
   
    var isPortraitMode: Bool = true
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
        DataDownloadManager.sharedInstance.errorHandler = self
        self.imageNameWithPathArray = [AnyObject]()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTableViewAppearence() {
        self.view.backgroundColor = UIColor(red: (5.0 / 255.0), green: (26.0 / 255.0), blue: (45.0 / 255.0), alpha: 1.0)
        self.customTableView.register(UINib(nibName: "HurricaneCell", bundle: nil), forCellReuseIdentifier: "HurricaneCellIdentifier")
        self.customTableView.register(UINib(nibName: "HurricaneCellTab2", bundle: nil), forCellReuseIdentifier: "HurricaneCellTab2")
        self.customTableView.register(UINib(nibName: "HurricaneCellTab3", bundle: nil), forCellReuseIdentifier: "HurricaneCellTab3")
        self.customTableView.register(UINib(nibName: "StormSurgeTableViewCell", bundle: nil), forCellReuseIdentifier: "StormSurgeTableViewCellIdentifier")
        self.customTableView.backgroundColor = AppDefaults.colorWithHexValue(Int(kBackgroundColor))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if self.navigationController != nil {// HAPP-516
            self.navigationController!.popViewController(animated: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.customTableView!.delegate = self
        self.customTableView!.dataSource = self
        self.view.frame = UIScreen.main.bounds
        /* Send a screen view to property */
        self.trackScreenName()
        self.setTableViewAppearence()
        self.setHeaderAppearance()
        self.setSegmentedControlAppearance()
        
    }

    func trackScreenName() {
        
        if self.checkStormsData() == false {
            return
        }
        
        let selectedObject: AnyObject? = self.stormCenterDetailArray?[self.segmentedControl.selectedSegmentIndex]
        if selectedObject != nil {
            if selectedObject is StormCenterDetail {
                self.screenName = kStormCenter
            } else if selectedObject is TropicWatchDetail {
                self.screenName = kTropicsWatch
            } else {
                self.screenName = kWatchesAndWarnings
            }
        }
    }

    func setTabsGANTrackEventWithCategory(_ category: String, withAction action: String, withLabel label: String?) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        let params = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: nil, value: nil).build() as [NSObject: AnyObject]
        tracker.send(params)
    }

    func trackEvent() {
        
        if self.checkStormsData() == false {
            return
        }
        
        let selectedObject: AnyObject? = self.stormCenterDetailArray?[self.segmentedControl.selectedSegmentIndex]
        if selectedObject != nil {
            if selectedObject is StormCenterDetail {
                for stormCenterDetail: AnyObject in self.stormCenterDetailArray! {
                    if (stormCenterDetail as! StormCenterDetail).index != nil {
                        if Int(truncating: (stormCenterDetail as! StormCenterDetail).index!) == self.segmentedControl.selectedSegmentIndex {
                            self.setTabsGANTrackEventWithCategory(kStormCenter, withAction: String(format: kTab, (stormCenterDetail as! StormCenterDetail).name!), withLabel: nil)
                        }
                    }
                }
            } else if selectedObject is TropicWatchDetail {
                for tropicWatchDetail: AnyObject in self.stormCenterDetailArray! {
                    if (tropicWatchDetail as! TropicWatchDetail).index != nil {// HAPP-513
                        if Int(truncating: (tropicWatchDetail as! TropicWatchDetail).index!) == self.segmentedControl.selectedSegmentIndex {
                            self.setTabsGANTrackEventWithCategory(kTropicsWatch, withAction: String(format: kTab, (tropicWatchDetail as! TropicWatchDetail).name!), withLabel: nil)
                        }
                    }
                }
            } else {
                for watchAndWarningDetail: AnyObject in self.stormCenterDetailArray! {
                    if (watchAndWarningDetail as! WatchesAndWarningsDetail).index != nil { // HAPP-512
                        if Int(truncating: (watchAndWarningDetail as! WatchesAndWarningsDetail).index!) == self.segmentedControl.selectedSegmentIndex {
                            self.setTabsGANTrackEventWithCategory(kWatchesAndWarnings, withAction: String(format: kTab, (watchAndWarningDetail as! WatchesAndWarningsDetail).name!), withLabel: nil)
                        }
                    }
                }
            }
        }
    }

    func contentWebViewWithHeight(_ height: CGFloat) {
        if floor(webViewHeight) == floor(height) {
            self.isWebViewLoaded = true
        } else {
            self.isWebViewLoaded = false
        }
        if self.isWebViewLoaded != true {
            webViewHeight = height
           
            self.customTableView.reloadData()
            self.customTableView.setContentOffset(CGPoint.zero, animated: false)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataDownloadManager.sharedInstance.delegate = self
        
        if self.isImageViewDidClose == false {
            self.setSegmentedControlIndexValues()
            self.reloadData()
        }
        self.isImageViewDidClose = false
        
        let adUnitId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kAdMobUnitId) as? String
        if adUnitId != nil && self.isAdReceived == false {
            self.showAdMobBannerWithAdUnitID(adUnitId!)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.trackEvent()
    }

    func showAdMobBannerWithAdUnitID(_ adUnitId: String) {
        let adMobViewController: AdMobViewController = AdMobViewController(nibName: "AdMobViewController", bundle: nil)
        adMobViewController.delegate = self
        self.view?.addSubview(adMobViewController.view)
        adMobViewController.loadAdMobBannerToClass(self, adUnitID: adUnitId)

    }

    func didSuccessToReceiveAd() {
        self.isAdReceived = true
        
        if self.imageViewController != nil {
            self.view!.bringSubviewToFront(self.imageViewController!.view!)
        }
        
        if self.segmentedControl.selectedSegmentIndex == 0 && self.isStormSurgeFound == true {
            // for storms - forecast cone - storm surge
            var tableFrame = self.customTableView.frame
            let tableFrameHeight = tableFrame.size.height - CGFloat(kAdMobAdHeight) - 3
            tableFrame.size.height = tableFrameHeight
            self.customTableView.frame = tableFrame
        }
        
    }
    
    func didSuccessToReceiveAd(ADHeight:CGFloat) {
        self.isAdReceived = true
        
        if self.imageViewController != nil {
            self.view!.bringSubviewToFront(self.imageViewController!.view!)
        }
        
        if self.segmentedControl.selectedSegmentIndex == 0 && self.isStormSurgeFound == true {
            // for storms - forecast cone - storm surge
            var tableFrame = self.customTableView.frame
            let tableFrameHeight = tableFrame.size.height - ADHeight - 3
            tableFrame.size.height = tableFrameHeight
            self.customTableView.frame = tableFrame
        }
    }

    func didFailToReceiveAd() {
        /* Nothing To Do Here */
        self.isAdReceived = false
        
        if self.segmentedControl.selectedSegmentIndex == 0 && self.isStormSurgeFound == true {
            // for storms - forecast cone - storm surge
            var tableFrame = self.customTableView.frame
            let tableFrameHeight = tableFrame.size.height - 3
            tableFrame.size.height = tableFrameHeight
            self.customTableView.frame = tableFrame
        }
        
    }

    func didAdViewPresentScreen() {
        self.delegate?.adViewDidPresentScreen()
    }

    func didAdViewDismissScreen() {
        self.delegate?.adViewDidDismissScreen()
    }

    func setHeaderAppearance() {
        self.subHeaderLabel.textColor = AppDefaults.colorWithHexValue(Int(kSubHeaderColor))
        self.subHeaderLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 31 : 15.79))// kCustomSubHeaderLabelFontSize)
        self.subHeaderLabel.textAlignment = .center
    }

    func setSegmentedControlAppearance() {
        var frame: CGRect = self.segmentedControl.frame
        frame.size.height = (IS_IPAD ? 54 : 27) // kSegmentControlHeight
        self.segmentedControl.tintColor = UIColor(red: (102.0 / 255.0), green: (140.0 / 255.0), blue: (72.0 / 255.0), alpha: 1.0)

        self.segmentedControl.backgroundColor = AppDefaults.colorWithHexValue(kSegmentBGColor)
    }

    func updateSegments() {
        
        if self.isTropicsWatch {
            self.stormCenterDetailArray = DataDownloadManager.sharedInstance.getTropicWatchData() as [AnyObject]?
        } else if self.isWatchesAndWarnings {
            self.stormCenterDetailArray = DataDownloadManager.sharedInstance.getWatchesAndWarningsData() as [AnyObject]?
        } else if self.needsStormsDataWithStormId != nil {
            let stormCenterArray = DataDownloadManager.sharedInstance.getStormDataforID(self.needsStormsDataWithStormId!)
            if stormCenterArray != nil {
                for stormCenter: Any in stormCenterArray! {
                    let indexBasedSort = NSSortDescriptor(key: "index", ascending: true)
                    let stormDetail = (stormCenter as! StormCenter).stormCenterDetail
                    if stormDetail != nil {
                        self.stormCenterDetailArray = (stormDetail!.allObjects as NSArray).sortedArray(using: [indexBasedSort]) as [AnyObject]
                    }
                }
            }
        }
       
        if(self.stormCenterDetailArray?.count > 0) {
            let segmentsArray =  Array.init(repeating: " ", count: self.stormCenterDetailArray!.count)
            self.segmentedControl.removeAllSegments()
            for segment in segmentsArray {
                self.segmentedControl.insertSegment(withTitle: segment, at: self.segmentedControl.numberOfSegments, animated: false)
                self.segmentedControl.selectedSegmentIndex = 0
            }
        }
       
    }

    func setSegmentedControlIndexValues() {
        self.updateSegments()
        
            // Crashlytics crash resolved
            if self.checkStormsData() == false {
                return
            }
        
            if let selectedObject: AnyObject =  self.stormCenterDetailArray?[self.segmentedControl.selectedSegmentIndex] {
                if selectedObject is StormCenterDetail {
                    // Storms Part
                    for stormObject: AnyObject in self.stormCenterDetailArray! {
                        if let stormCenterDetail = stormObject as? StormCenterDetail {
                            
                            if let stormCenter = selectedObject.stormCenter as? StormCenter {
                               
                                if stormCenter.stormSurge != nil {
                                    self.isStormSurgeFound = true
                                    print(stormCenter.stormSurge!)
                                    self.stormSurgeURL = stormCenter.stormSurge!
                               
                                }
                                
                            }
                            self.delegate?.setNavigationTitle(pTitle: stormCenterDetail.stormCenter?.stormName ?? "")
                            self.subHeaderLabel.text = stormCenterDetail.stormCenter?.subhead ?? ""
                            if stormCenterDetail.index != nil {// HAPP-503
                                if Int(truncating: stormCenterDetail.index!) <  self.segmentedControl.numberOfSegments && Int(truncating: stormCenterDetail.index!) >= 0 { // HAPP-503
                                    self.segmentedControl.setTitle(stormCenterDetail.name ?? "", forSegmentAt: Int(truncating: stormCenterDetail.index!))
                                }
                            }
                            if stormCenterDetail.stormCenter != nil {// HAPP-503
                                if stormCenterDetail.stormCenter!.idx != nil {// HAPP-503
                                    self.currentIdx = stormCenterDetail.stormCenter!.idx
                                }
                            }
                            self.saveImageInBackground(stormCenterDetail.imageURL ?? "", imagePath: stormCenterDetail.imageNameWithPath ?? "")
                            /* Download All Loop Images In Background */
                            // HAPP-591
                            if stormCenterDetail.stormCenterImages != nil {
                                for stormObject: Any in stormCenterDetail.stormCenterImages! {
                                    let stormCenterImages = stormObject as! StormCenterImages
                                    self.saveImageInBackground(stormCenterImages.imageURL, imagePath: stormCenterImages.imageNameWithPath)
                                }
                            }
                            
                        }
                    }
                } else if selectedObject is TropicWatchDetail {
                    if self.stormCenterDetailArray != nil {
                        for tropicWatchObject: AnyObject in self.stormCenterDetailArray! {
                            // Tropics part
                            if let tropicWatchDetail = tropicWatchObject as? TropicWatchDetail {
                                self.delegate?.setNavigationTitle(pTitle: tropicWatchDetail.tropicWatch?.name ?? "")
                                self.subHeaderLabel.text = tropicWatchDetail.tropicWatch?.subhead ?? ""
                                self.segmentedControl.setTitle(tropicWatchDetail.name, forSegmentAt: Int(truncating: tropicWatchDetail.index!))
                                self.currentIdx = tropicWatchDetail.tropicWatch!.idx
                                self.saveImageInBackground(tropicWatchDetail.imageURL, imagePath: tropicWatchDetail.imageNameWithPath)
                                /* Download All Loop Images In Background */
                                if tropicWatchDetail.tropicWatchImages != nil {
                                    for tropicObject: Any in tropicWatchDetail.tropicWatchImages! {
                                        let tropicWatchImages = tropicObject as! TropicWatchImages
                                        self.saveImageInBackground(tropicWatchImages.imageURL, imagePath: tropicWatchImages.imageNameWithPath)
                                    }
                                }
                                
                            }
                        }
                    }
        } else {
            for watchAndWarningDetail: AnyObject in self.stormCenterDetailArray! {
                if let watchDetail = watchAndWarningDetail as? WatchesAndWarningsDetail {
                self.delegate?.setNavigationTitle(pTitle: watchDetail.watchesAndWarnings?.name ?? "")
                self.title = watchDetail.watchesAndWarnings?.name ?? ""
            
                self.subHeaderLabel.textColor = UIColor.white
                    self.subHeaderLabel.backgroundColor = UIColor.clear
                self.subHeaderLabel.isHidden = true
                    
                    var segFrame = self.segmentedControl.frame
                    segFrame.origin.y = 35
                    self.segmentedControl.frame = segFrame
                    
                    var tableFrame = self.customTableView.frame
                    tableFrame.origin.y = segFrame.origin.y + segFrame.size.height + 10
                    tableFrame.size.height = self.view.frame.size.height - tableFrame.origin.y
                    self.customTableView.frame = tableFrame
                    
                if IS_IPAD {
                    self.subHeaderLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: 50)
                } else {
                    self.subHeaderLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: 30)
                }
                self.segmentedControl.setTitle(watchDetail.name, forSegmentAt: Int(truncating: watchDetail.index!))
                self.currentIdx = watchDetail.watchesAndWarnings!.idx
                self.saveImageInBackground(watchDetail.imageURL, imagePath: watchDetail.imageNameWithPath)
            }
            }
        }
        }
    }
    
    func checkStormsData() -> Bool {
        
        if self.stormCenterDetailArray != nil {
            if self.stormCenterDetailArray?.count == 0 {
                return false
            } else if self.stormCenterDetailArray!.count > self.segmentedControl.selectedSegmentIndex {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
        
    }

    func saveImageInBackground(_ imageUrl: String?, imagePath: String?) {
        if imageUrl != nil && imagePath != nil {
            let requestURL = URL(string: imageUrl!)
            if requestURL != nil {
                let imageRequest: URLRequest = URLRequest(url: requestURL!)
                let task = URLSession.shared.dataTask(with: imageRequest) {
                    data, _, error in
                    if error == nil {
                        if data != nil {
                            do {
                                try data!.write(to: URL(string: imagePath!)!, options: [.atomic])
                            } catch let error {
                                print("Error in saving image: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isStormSurgeFound == false {
            return 1
        } else if self.segmentedControl.selectedSegmentIndex == 0 && self.isStormSurgeFound == true {
            return 2
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let imageHeight: CGFloat = (9.0 / 16.0) * UIScreen.main.bounds.width
            
            var webContentHeight: CGFloat = 0.0
            webContentHeight = max(webViewHeight, self.customTableView.frame.size.height - imageHeight)
            
            if self.segmentedControl.selectedSegmentIndex == 0 && self.isStormSurgeFound == true {
                // for storm - forecast cone + storm surge
                return (imageHeight + webViewHeight) + 27
                
            } else {
                
                if self.screenName == kWatchesAndWarnings {
                    // for watches and warnings
                    return (imageHeight + webContentHeight + 20 + (IS_IPAD ? 160 : 80))
                    
                } else {
                    return (imageHeight + webViewHeight) + 37 + (IS_IPAD ? 160 : 80)
                }
              
            }
            
        } else if indexPath.row == 1 {
            // for storm - forecast cone + storm surge
            return ((9.0 / 16.0) * self.view.frame.size.width) + (IS_IPAD ? 40 : 30)
            
        } else {
            return 0
        }
    }

    func configureCell(_ cell: HurricaneCell, atIndexPath indexPath: IndexPath) {
        
        if self.checkStormsData() == false {
            return
        }
        
        let selectedObject: AnyObject = self.stormCenterDetailArray![self.segmentedControl.selectedSegmentIndex]
        self.showMapFullScreen = false
        if selectedObject is StormCenterDetail {
            self.imageNameWithPathArray?.removeAll() // HAPP-591
            let stormCenterDetail = selectedObject as! StormCenterDetail
            self.loadHTMLContent(stormCenterDetail.discussion, cell: cell)

            // HAPP-591
            if stormCenterDetail.stormCenterImages != nil {// HAPP-509
                let stormCenterImagesArray: [Any] =  (stormCenterDetail.stormCenterImages!.allObjects as NSArray) as! [Any]

                for stormCenterImages: Any in stormCenterImagesArray {
                    let imgPath = (stormCenterImages as! StormCenterImages).imageNameWithPath
                    if imgPath != nil {
                        self.imageNameWithPathArray?.append(imgPath! as AnyObject)
                    }
                }
            }
            /* Show Image */
            if stormCenterDetail.mapData != nil {
                let data = stormCenterDetail.mapData!
                //let unarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
                
                do {
                    if let unarchiveObject = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSString.self,NSArray.self,NSNumber.self], from: data as Data) {
                        let mapDict = unarchiveObject as? [String: Any]
                        self.mapDict = mapDict
                        if self.mapDict != nil {
                            if stormCenterDetail.discussion == nil {
                                self.showMapFullScreen = true
                            }
                            self.displayInteractiveMap(cell)
                        }                        }
                        
                   } catch {
                       print("loadWidgetDataArray - Can't encode data: \(error)")
                   }
               
            } else {
               self.displayImageforStormView(cell, imagePath: stormCenterDetail.imageNameWithPath, imageUrl: stormCenterDetail.imageURL)
            }
        } else if selectedObject is TropicWatchDetail {
            let tropicWatchDetail: TropicWatchDetail = selectedObject as! TropicWatchDetail
            self.loadHTMLContent(tropicWatchDetail.discussion, cell: cell)
            self.imageNameWithPathArray?.removeAll()
            let indexBasedSort: NSSortDescriptor = NSSortDescriptor(key: "index", ascending: true)
            if tropicWatchDetail.tropicWatchImages != nil {// HAPP-509
                let tropicWatchImagesArray: [Any] =  (tropicWatchDetail.tropicWatchImages!.allObjects as NSArray) .sortedArray(using: [indexBasedSort])
                for tropicWatchImages: Any in tropicWatchImagesArray {
                    let imgPath = (tropicWatchImages as! TropicWatchImages).imageNameWithPath
                    if imgPath != nil {
                        self.imageNameWithPathArray?.append(imgPath! as AnyObject)
                    }
                }
            }
            
            self.loop_gif = tropicWatchDetail.loop_gif

            /* Show Image */
            if tropicWatchDetail.mapData != nil {
                let data = tropicWatchDetail.mapData!
               // let unarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
                
                do {
                    if let unarchiveObject = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSString.self,NSArray.self,NSNumber.self], from: data as Data) {
                        let mapDict = unarchiveObject as? [String: Any]
                        self.mapDict = mapDict
                        if self.mapDict != nil {
                            if tropicWatchDetail.discussion == nil {
                                self.showMapFullScreen = true
                            }
                            self.displayInteractiveMap(cell)
                        }
                        
                    }
                        
                   } catch {
                       print("loadWidgetDataArray - Can't encode data: \(error)")
                   }
                
            } else {
                self.displayImageforStormView(cell, imagePath: tropicWatchDetail.imageNameWithPath, imageUrl: tropicWatchDetail.imageURL)
            }
        } else if selectedObject is WatchesAndWarningsDetail {
            let watchesAndWarningsDetail: WatchesAndWarningsDetail = (selectedObject as! WatchesAndWarningsDetail)
            self.loadHTMLContent(watchesAndWarningsDetail.discussion, cell: cell)
            /* Show Image */
            if watchesAndWarningsDetail.mapData != nil {
                let data = watchesAndWarningsDetail.mapData!
               // let unarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data)
                
                do {
                    if let unarchiveObject = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSString.self,NSArray.self,NSNumber.self], from: data as Data) {
                            let mapDict = unarchiveObject as? [String: Any]
                            self.mapDict = mapDict
                            if self.mapDict != nil {
                                if watchesAndWarningsDetail.discussion == nil {
                                    self.showMapFullScreen = true
                                }
                                self.displayInteractiveMap(cell)
                            }
                        }
                        
                   } catch {
                       print("loadWidgetDataArray - Can't encode data: \(error)")
                   }
               
            } else {
                self.displayImageforStormView(cell, imagePath: watchesAndWarningsDetail.imageNameWithPath, imageUrl: watchesAndWarningsDetail.imageURL)
            }
        } else {
            NSLog("********** Unable To Get Correct Class **********")
            MBProgressHUD.hide(for: cell.stormImageView, animated: true)
        }

        if self.displayMap {
            var frame = self.maxMap.view.frame
            if self.showMapFullScreen {
                frame.size.height = self.customTableView.frame.size.height
                self.maxMap.view?.frame = frame
                maxMap.updateFrame(self.customTableView.frame)
            } else {
                frame.size.height = (9.0 / 16.0) * self.customTableView.frame.size.width
                self.maxMap.view?.frame = frame
                maxMap.updateFrame((self.maxMap.view?.frame)!)
            }

            frame = cell.contentWebView.frame
            frame.size.height = 0
            cell.contentWebView.frame = frame
            cell.tapToZoomLabel.isHidden = true
            cell.zoomLabelBackground.isHidden = true
            if self.tapOnImage != nil {
                cell.stormImageView.removeGestureRecognizer(self.tapOnImage!)
            }
        } else {
            cell.tapToZoomLabel.isHidden = false // HAPP-597
            cell.zoomLabelBackground.isHidden = false // HAPP-597
            self.addTapGesturesToCell(cell) // HAPP-597
            var frame: CGRect = cell.stormImageView.frame
            frame.size.width = self.customTableView.frame.size.width
            frame.size.height = (9.0 / 16.0) * self.view.frame.size.width
            cell.stormImageScrollView.frame = frame
            cell.stormImageView.frame = frame
            cell.stormImageScrollView.contentSize = frame.size

            frame = cell.zoomLabelBackground.frame
            frame.origin.y = cell.stormImageView.frame.size.height - frame.size.height
            frame.size.width = self.customTableView.frame.size.width
            cell.zoomLabelBackground.frame = frame
            frame = cell.tapToZoomLabel.frame
            frame.origin.y = cell.stormImageView.frame.size.height - frame.size.height
            frame.size.width = self.customTableView.frame.size.width - 15
            cell.tapToZoomLabel.frame = frame

            frame = cell.mapBottomLineLabel.frame
            frame.origin.y = cell.stormImageView.frame.size.height
            frame.size.width = self.customTableView.frame.size.width
            cell.mapBottomLineLabel.frame = frame
            frame = cell.contentWebView.frame
            frame.origin.y = cell.stormImageView.frame.size.height + 27
            frame.size.width = self.customTableView.frame.size.width - 2 * frame.origin.x
            cell.contentWebView.frame = frame
        }
        cell.contentView.sizeToFit()

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
           
            var hurricaneCellIdentifier: String = ""
            
            if self.segmentedControl.selectedSegmentIndex == 0 {
                hurricaneCellIdentifier = "HurricaneCellIdentifier"
                
            } else if self.segmentedControl.selectedSegmentIndex == 1 {
                hurricaneCellIdentifier = "HurricaneCellTab2"
            } else if self.segmentedControl.selectedSegmentIndex == 2 {
                hurricaneCellIdentifier = "HurricaneCellTab3"
            }
            
            let cell: HurricaneCell = (tableView.dequeueReusableCell(withIdentifier: hurricaneCellIdentifier) as! HurricaneCell)
            cell.delegate = self
            cell.stormImageView.image = nil
            cell.stormImageScrollView.zoomScale = 1
            self.configureCell(cell, atIndexPath: indexPath)
          
            return cell
        } else {
            let stormSurgeCellIdentifier: String = "StormSurgeTableViewCellIdentifier"
            let cell: StormSurgeTableViewCell = (tableView.dequeueReusableCell(withIdentifier: stormSurgeCellIdentifier) as! StormSurgeTableViewCell)
            cell.titleLabel.text = self.stormSurgeTitle
            cell.stormSurgeImage.sd_setImage(with: URL(string: self.stormSurgeURL))
            
            return cell
        }
        
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: (5.0 / 255.0), green: (26.0 / 255.0), blue: (45.0 / 255.0), alpha: 1.0)
    }

    func loadHTMLContent(_ webContent: String?, cell: HurricaneCell) {
        if webContent != nil {
            let updatedContent = AppDefaults.getUpdatedContent(webContent!)
            if updatedContent != nil {
                // HAPP-449 Migrate UIWebView To WKWebView.
                let addblankLines: String! = "<p></p><p></p><p></p>"
                // added blank lines at bottom due to last line gets cut(document.body.offsetHeight)

                let cssPath: String? = Bundle.main.path(forResource: "HTMLstyling", ofType: "css")
                if cssPath != nil {
                    let cssURL: URL = URL(fileURLWithPath: cssPath!)
                    cell.contentWebView.loadHTMLString((AppDefaults.getHeaderForWKWebView()!) + AppDefaults.getHTMLStringFromString( updatedContent! + addblankLines), baseURL: cssURL)
                }
            }
        }
    }

    func displayImageforStormView(_ cell: HurricaneCell, imagePath: String?, imageUrl: String?) {
        self.displayMap = false
        var imageData: Data?
        if imagePath != nil {
            let url = URL(string: imagePath!)
            if url != nil {
                imageData = try? Data(contentsOf: url!)
            }
        }

        if imageData != nil {
            cell.stormImageView.image = UIImage(data: imageData!)
        } else {
            
            let imageURLStr = imageUrl
            
            if imageURLStr != nil {
                cell.imageURL = imageURLStr!
                let imgUrl = URL(string: imageURLStr!)
                if imgUrl != nil {
                    MBProgressHUD.hide(for: cell.stormImageView, animated: true)
                    MBProgressHUD.showAdded(to: cell.stormImageView, animated: true)
                    cell.stormImageView.imageFromUrl(url: imgUrl!)
                }
                
            }
        }
    }

    func addTapGesturesToCell(_ cell: HurricaneCell) {
        if self.tapOnImage == nil {
            self.tapOnImage = UITapGestureRecognizer(target: self, action: #selector(CustomViewController.handleTapGesture(_:)))
            self.tapOnImage?.numberOfTapsRequired = 1
        }
        let tapOnLabel: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CustomViewController.handleTapGesture(_:)))
        tapOnLabel.numberOfTapsRequired = 1
        cell.stormImageView.addGestureRecognizer(self.tapOnImage!)
        cell.tapToZoomLabel.isUserInteractionEnabled = true
        cell.tapToZoomLabel.addGestureRecognizer(tapOnLabel)
    }

    func imageViewDidDisplay() {
        self.delegate?.imageViewDidDisplay()
    }

    func imageViewDidClose() {
        self.isImageViewDidClose = true
        self.imageViewController = nil
        let topPaddingInsets = AppDefaults.getTopPadding()
        if topPaddingInsets > 0.0 {
            var screenFrame: CGRect = UIScreen.main.bounds
            screenFrame.origin.y = topPaddingInsets + kTopPadding/3
            screenFrame.size.height = screenFrame.size.height - screenFrame.origin.y - (IS_IPAD ? (self.tabBarController?.tabBar.frame.size.height ?? 0) : 0) - AppDefaults.getBottomPadding() - 20 // HAPP-522, 20 for AD issue
            self.view.frame = screenFrame
        } else {
            var screenFrame: CGRect = UIScreen.main.bounds
            
            if !self.isPortraitMode {
                
                let wdh = screenFrame.size.width
                let ht = screenFrame.size.height
                
                screenFrame.size.height = wdh
                screenFrame.size.width = ht
            }
            
            screenFrame.origin.y = 48 + kTopPadding/3
            screenFrame.size.height = screenFrame.size.height - screenFrame.origin.y - (IS_IPAD ? (self.tabBarController?.tabBar.frame.size.height ?? 0) : 0) - AppDefaults.getBottomPadding() - 20
            self.view.frame = screenFrame
        }
        self.navigationController!.isNavigationBarHidden = false
        isStatusBarHidden = false
        self.setNeedsStatusBarAppearanceUpdate()
        self.delegate?.imageViewDidClose()
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        let tapLocation: CGPoint = sender.location(in: self.customTableView)
        if let tappedIndexPath =  self.customTableView.indexPathForRow(at: tapLocation) {// HAPP-511
            let cell: HurricaneCell = (self.customTableView.cellForRow(at: tappedIndexPath) as! HurricaneCell)
            self.zoomRequiredOnCell(cell)
        }
    }

    func zoomRequiredOnCell(_ cell: HurricaneCell) {
        var screenFrame: CGRect = UIScreen.main.bounds
        screenFrame.origin.y = 0.0
        self.view.frame = screenFrame
        if self.navigationController != nil {
            self.navigationController!.isNavigationBarHidden = true
        }
        isStatusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        self.imageViewController = ImageViewController(nibName: "ImageViewController", bundle: nil)
        self.imageViewController!.delegate = self
        let relativeY: CGFloat = cell.frame.origin.y - self.customTableView.contentOffset.y
        self.imageViewController!.relativeY = relativeY
        self.imageViewController!.animationImageViewArray = self.imageNameWithPathArray as NSArray?
        self.imageViewController!.loop_gif = self.loop_gif
        self.imageViewController!.selectedImage = cell.stormImageView
        self.imageViewController!.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(self.imageViewController!, animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    
    

    @IBAction func segmentIndexChanged(_ sender: AnyObject) {
       self.reloadData()
       self.trackEvent()
    }

    func reloadData() {
        self.isWebViewLoaded = false
        if self.displayMap {
            timer?.invalidate()
            timer = nil
            self.maxMap.willMove(toParent: nil)
            self.maxMap.view.removeFromSuperview()
            self.maxMap.removeFromParent()
        }

        self.customTableView.reloadData()
    }

    func refreshData() {
        self.downloadAllData()
    }

    @objc func refreshButtonTapped(_ sender: AnyObject) {
        self.refreshData()
    }

    func downloadAllData() {
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.parent!.navigationController!.view!, animated: true)
        hud.labelText = kHUDLabelText
        DataDownloadManager.sharedInstance.downloadAllData()
    }

    func didSuccess(toSaveData isSuccess: Bool) {
        if let parent = self.parent {
            if self.navigationController != nil {// HAPP-530
                MBProgressHUD.hide(for: parent.navigationController!.view!, animated: true)
            }
        }
        if !isSuccess {
            return
        }
        if self.currentIdx != nil { // HAPP-529
        let entity: String? = DataDownloadManager.sharedInstance.getEntityForId(self.currentIdx!)
        if entity != nil && entity != "" {
            let dataArray: [Any]? = DataDownloadManager.sharedInstance.getDataForEntity(entity!, id: self.currentIdx!)
            if dataArray != nil {
                let selectedObject = dataArray!.last
                if selectedObject is StormCenter {
                    for stormCenter: Any in dataArray! {
                        let indexBasedSort: NSSortDescriptor = NSSortDescriptor(key: "index", ascending: true)
                        self.stormCenterDetailArray = ((stormCenter as! StormCenter).stormCenterDetail!.allObjects as NSArray).sortedArray(using: [indexBasedSort]) as [AnyObject]
                    }
                } else if selectedObject is TropicWatch {
                    for tropicWatch: Any in dataArray! {
                        let indexBasedSort: NSSortDescriptor = NSSortDescriptor(key: "index", ascending: true)
                        self.stormCenterDetailArray = ((tropicWatch as! TropicWatch).tropicWatchDetail!.allObjects as NSArray).sortedArray(using: [indexBasedSort]) as [AnyObject]
                    }
                } else if selectedObject is WatchesAndWarnings {
                    for watchesAndWarnings: Any in dataArray! {
                        let indexBasedSort: NSSortDescriptor = NSSortDescriptor(key: "index", ascending: true)
                        self.stormCenterDetailArray = ((watchesAndWarnings as! WatchesAndWarnings).watchesAndWarningsDetail!.allObjects as NSArray).sortedArray(using: [indexBasedSort]) as [AnyObject]
                    }
                } else {

                    /* Do Nothing */
                }

                self.setSegmentedControlIndexValues()
                self.reloadData()
                self.trackEvent()
            }
        } else {
            if self.navigationController != nil {
                self.navigationController!.popToRootViewController(animated: true)
            }
        }
        } else {
            if self.navigationController != nil {// HAPP-529
                self.navigationController!.popToRootViewController(animated: true)
            }
        }
    }

    func displayInteractiveMap(_ cell: HurricaneCell) {
        self.displayMap = true
        self.maxMap = MaxMapViewController.sharedInstance
        self.addChild(self.maxMap)
        var frame = self.maxMap.view.frame
        if frame.origin.y == 20 {
            frame.origin.y = 0
        }
        if self.showMapFullScreen {
            frame.size.height = self.customTableView.frame.size.height
            frame.size.width = self.view.frame.size.width
            self.maxMap.view?.frame = frame
            maxMap.updateFrame(self.customTableView.frame)
            cell.contentView.addSubview(self.maxMap.view!)
        } else {
            frame.size.height = (9.0 / 16.0) * self.customTableView.frame.size.width
            self.maxMap.view?.frame = frame
            maxMap.updateFrame((self.maxMap.view?.frame)!)
            cell.stormImageView.addSubview(self.maxMap.view!)
        }

        let coordinate: CLLocationCoordinate2D = CoreLocationManager.sharedInstance.getCurrentLocation()
        var locationCoordinate =  CLLocationCoordinate2D()
        if let cordDict = self.mapDict?["initial_coords"] as? [AnyHashable: Any] {
            let cordLat = cordDict["lat"] as? Double
            let cordLon = cordDict["lon"] as? Double
            if cordLat != nil && cordLon != nil {
                locationCoordinate.latitude = cordLat!
                locationCoordinate.longitude = cordLon!
            } else {
                locationCoordinate = coordinate
            }
        } else {
            locationCoordinate = coordinate
        }
        let zoomDict = self.mapDict?["zoom"] as? [AnyHashable: Any]
        var zoomX: Double?
        var zoomY: Double?
        if zoomDict != nil {
            zoomX = zoomDict!["zoom_x"] as? Double
            zoomY = zoomDict!["zoom_y"] as? Double
        }
        if zoomX == nil || zoomY == nil {
            zoomX = 5.0
            zoomY = 5.0
        }

        let region = WSIMapSDKRegionMake(locationCoordinate, 3.0)
              maxMap.wsiSDK!.setMapRegion(region, animated: false)
        maxMap.checkedLoactionPermission(cordinates: coordinate)

        if maxMap.layerDict == nil {
            if timer == nil {
                self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(LiveMapViewController.loadActiveLayer), userInfo: nil, repeats: true)
            }
        } else {
            self.loadActiveLayer()
        }
    }

    @objc func loadActiveLayer() {
        // Layers
        if maxMap.layerDict != nil {
            timer?.invalidate()
            timer = nil
            var layer = self.mapDict!["layer"] as? String
            if layer != nil && layer != "" {
                let mappingDictKeys = (maxMap.wsiLayersMappingDict as NSDictionary).allKeys as? [String]
                if mappingDictKeys!.contains(layer!) {
                    layer = maxMap.wsiLayersMappingDict[layer!] as? String
                }
                maxMap.wsiSDK.setActiveRasterLayer(maxMap.layerDict![layer!] as? WSIMapSDKMapObject)
            } else {
                maxMap.wsiSDK.setActiveRasterLayer(nil)
            }
            // Overlays
            var overlays = self.mapDict!["overlays"] as? [String]
            if overlays != nil {
                for overlayName in overlays! {
                    let mappingDictKeys = (maxMap.wsiLayersMappingDict as NSDictionary).allKeys as? [String]
                    if mappingDictKeys!.contains(overlayName) {
                        let newOverlay = maxMap.wsiLayersMappingDict[overlayName] as? String
                        if newOverlay != nil {
                            overlays!.remove(at: (overlays!.firstIndex(of: overlayName))!)
                            overlays!.append(newOverlay!)
                        }
                    }
                }
            }
            let overlaysList = maxMap.overlayList
            for overlay: AnyObject in overlaysList {
                if overlays != nil {
                    if overlays!.contains((overlay as! WSIMapSDKMapObject).getLayerID()) {
                        maxMap.wsiSDK.setStateForOverlay(overlay as! WSIMapSDKMapObject, active: true)

                    } else {
                        maxMap.wsiSDK.setStateForOverlay(overlay as! WSIMapSDKMapObject, active: false)
                    }
                } else {
                    maxMap.wsiSDK.setStateForOverlay(overlay as! WSIMapSDKMapObject, active: false)
                }
            }
             // Alerts
            let mappingAlertDictKeys = (maxMap.wsiAlertMappingDict as NSDictionary).allKeys as? [String]
            for key: String in mappingAlertDictKeys! {
                maxMap.wsiSDK.disableAlertCategory(maxMap.wsiAlertMappingDict[key] as! String)
            }
                for overlayObj: String in overlays! {
                    if mappingAlertDictKeys!.contains(overlayObj) {
                        maxMap.wsiSDK.enableAlertCategory(maxMap.wsiAlertMappingDict[overlayObj] as! String)
                        maxMap.wsiSDK.setStateForOverlay(maxMap.categoryDict["wsi_WeatherAlertsAll"] as! WSIMapSDKMapObject, active: true)
                    } else {

                    }
                }

            let tranparency = self.mapDict!["transparency"] as? UInt
            if tranparency != nil {
                maxMap.wsiSDK.setTransparencyPercentForActiveRasterLayer(tranparency!)
            }
            if self.mapDict!["loop"] != nil {
                let shouldActivateLoop: Bool? = self.mapDict!["loop"] as? Bool
                if shouldActivateLoop == true {
                    maxMap.wsiSDK.setIsLooping(true)
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
        super.viewWillDisappear(animated)
        
        self.takeSnapShotOfView()
       
    }

    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @objc func orientationChanged() {
        let currentOrientation = UIDevice.current.orientation
        print("oriiii \(currentOrientation)")
        if currentOrientation == .landscapeLeft || currentOrientation == .landscapeRight {
            self.isPortraitMode = false
        } else if currentOrientation == .portrait || currentOrientation == .portraitUpsideDown {
            self.isPortraitMode = true
        }
            
    }
}
