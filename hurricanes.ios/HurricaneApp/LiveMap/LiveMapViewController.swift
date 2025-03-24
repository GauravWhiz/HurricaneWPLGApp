//
//  LiveMapViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 16/06/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//
import Foundation
import UIKit
import CoreLocation

class LiveMapViewController: GAITrackedViewController, AdMobViewControllerDelegate, MaxMapViewDelegate, UIGestureRecognizerDelegate {
    var mapDict: [AnyHashable: Any]?
    var isLocalRadar: Bool = false
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var timestampView: UIView!
    @IBOutlet weak var activeLayerTime: UILabel!
    @IBOutlet weak var legendBackgroundView: UIView!
    @IBOutlet weak var legendImageView: UIImageView!
    var layerButton = UIButton()
    var sliderBackgroundView = UIView() // HAPP-650
    var timeslider = UISlider() // HAPP-650
    var startTimeImageView = UIImageView() // HAPP-650
    var endTimeImageView = UIImageView() // HAPP-650
    var playPauseButtonBgView = UIView()
    var sliderBgView = UIView()
    var sliderBgBorderView = UIView()
    var startTimeLabel = UILabel()
    var endtimeLabel = UILabel()
    var timeLable = UILabel()
    var playPauseButton = UIButton()
    var isPlaying = Bool()
    var isLandscapeRequired: Bool = false
    var isLayerActive: Bool = false
    var isLoopActive: Bool = false
    var timer: Timer?
    private var isBannerAdReceived = false
    var maxMap: MaxMapViewController?
    @IBOutlet var titleText: UILabel!
    var tapGesture = UITapGestureRecognizer()
    @IBOutlet var descriptionText: UILabel!
    var displayTitle: String?
    var zoom_level: Double!
    
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
        // Do any additional setup after loading the view from its nib.

        self.maxMap = MaxMapViewController.sharedInstance

        self.view.frame = UIScreen.main.bounds
        if self.isLocalRadar {
            self.screenName = "Precipitation"
            zoom_level = 8.0

            var radarLayers = [AnyObject]()
            radarLayers = AppDefaults.getRadarLayers()

            if radarLayers.count > 0 {
                let dict: [String: Any] = radarLayers[0] as! [String: Any]
                var userData: [AnyHashable: Any] = dict["map"] as! [AnyHashable: Any]

                if let object = dict["title"] {
                    userData["title"] = object
                    userData["sectionTitle"] = object
                }
                self.mapDict = userData
            } else {

                let dict = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "WSI_MAXMAP_LOCALRADAR") as? [AnyHashable: Any]
                if dict != nil {
                    self.mapDict = dict!
                }
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateActiveLayers(notification: )), name: NSNotification.Name("NotificationdidUpdateLayer"), object: nil)
        } else {
            self.screenName = kStormTracker
            zoom_level = 1.2

            let dict = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: "WSI_MAXMAP_STORMTRACKER") as? [AnyHashable: Any]
            if dict != nil {
                self.mapDict = dict!
            }
        }
        self.backgroundView.alpha = 1.0
        self.backgroundView.isUserInteractionEnabled = true
        displayTitle = self.screenName
        self.timestampView.isHidden = true
        if displayTitle != nil {
            AppDefaults.setNavigationBarTitle(displayTitle!, self.view)
        }

        self.view.backgroundColor = kViewBackgroundColor
        self.timestampView.backgroundColor = AppDefaults.colorWithHexValue(kWebViewControlsBgColor)
        self.timestampView.layer.cornerRadius = 12.0

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let statusBarHeight = UIApplication.shared.statusBarHeight
        var frame = UIScreen.main.bounds
        frame.origin.y = statusBarHeight+navigationBarHeight
        frame.size.height = frame.size.height - frame.origin.y
        if(self.isBannerAdReceived == false) {
            self.backgroundView.frame = frame
        }

        if self.isLocalRadar {
            self.maxMap?.delegate = self
        }
        if self.maxMap != nil {
            self.addChild(self.maxMap!)
            backgroundView.addSubview(self.maxMap!.view)
        }

        frame.origin.y = 0.0
        self.maxMap?.view.frame = frame
        self.maxMap?.wsiSDK.mapView.frame = frame
        if maxMap?.wsiSDK != nil {
            self.showInteractiveMap()
        } else {
            self.titleText.isHidden = false
            self.descriptionText.isHidden = false
        }
        let adUnitId = FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kAdMobUnitId) as? String
        if adUnitId != nil && self.isBannerAdReceived == false {
            self.showAdMobBannerWithAdUnitID(adUnitId!)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        BlueconicHelper.createBlueconicEvent(self, forPageView: "Main/LiveMapViewController")
        if isLocalRadar {
            let currentLocation: CLLocationCoordinate2D = CoreLocationManager.sharedInstance.getCurrentLocation()
            #if TARGET_IPHONE_SIMULATOR
            // Seted zoom level 1.0 for simulator because of app is crashing on Xcode 13.3.1 simulator.
                self.maxMap?.wsiSDK.setMapCenter(currentLocation, zoomLevel: 1.0, animated: false)
            #else
                self.maxMap?.wsiSDK.setMapCenter(currentLocation, zoomLevel: kInitialZoomLevel, animated: false)

            #endif
            self.updateLayerimageview()
        } else
        {
            self.legendBackgroundView.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        maxMap?.wsiSDK.setIsLooping(false) // HAPP-650 commenting it for added slider
        timer?.invalidate()
        self.isLoopActive = false
        super.viewWillDisappear(animated)
        
        self.takeSnapShotOfView()
    }

    func showAdMobBannerWithAdUnitID(_ adUnitId: String) {
        let adMobViewController: AdMobViewController = AdMobViewController(nibName: "AdMobViewController", bundle: nil)
        adMobViewController.delegate = self
        self.view?.addSubview(adMobViewController.view)
        adMobViewController.loadAdMobBannerToClass(self, adUnitID: adUnitId)

    }

    func didSuccessToReceiveAd() {
        var frame: CGRect = self.backgroundView.frame
        //frame.size.height = self.view.frame.size.height - (CGFloat(kAdMobAdHeight)+AppDefaults.getBottomPadding())
        frame.size.height = frame.size.height - (CGFloat(kAdMobAdHeight)+AppDefaults.getBottomPadding())
        self.backgroundView.frame = frame
        maxMap?.updateFrame(frame)
        self.isBannerAdReceived = true
        self.updateLayerButtonFrame()
    }
    
    func didSuccessToReceiveAd(ADHeight:CGFloat) {
        var frame: CGRect = self.backgroundView.frame
        //frame.size.height = self.view.frame.size.height - (CGFloat(kAdMobAdHeight)+AppDefaults.getBottomPadding())
        frame.size.height = frame.size.height - (ADHeight+AppDefaults.getBottomPadding())
        self.backgroundView.frame = frame
        maxMap?.updateFrame(frame)
        self.isBannerAdReceived = true
        self.updateLayerButtonFrame()
    }

    func didFailToReceiveAd() {
        /* Nothing To Do Here */
        self.isBannerAdReceived = false
    }

    func didAdViewPresentScreen() {
        self.isLandscapeRequired = true
    }

    func didAdViewDismissScreen() {
        self.isLandscapeRequired = false
    }

    func showInteractiveMap() {
        // create and initialize WSI SDK
        // set up initial geographical map size and location

        let panGesture =  UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(gestureRecognizer:)))
        panGesture.delegate = self
        self.maxMap?.wsiSDK.mapView.addGestureRecognizer(panGesture)

        let coordinate: CLLocationCoordinate2D = CoreLocationManager.sharedInstance.getCurrentLocation()
        var locationCoordinate =  CLLocationCoordinate2D()
        let cordDict = self.mapDict?["initial_tracker_coords"] as? [AnyHashable: Any]
        if cordDict != nil {
            let cordLat = cordDict!["lat"] as? Double
            let cordLon = cordDict!["lon"] as? Double
            if cordLat != nil && cordLon != nil {
                locationCoordinate.latitude = cordLat!
                locationCoordinate.longitude = cordLon!
            } else {
                locationCoordinate = coordinate
            }
        } else {
            locationCoordinate = coordinate
        }
        let zoomDict = self.mapDict?["initial_tracker_zoom"] as? [AnyHashable: Any]
        var zoomX: Double?
        var zoomY: Double?
        if zoomDict != nil {
            zoomX = zoomDict!["zoom_x"] as? Double
            zoomY = zoomDict!["zoom_y"] as? Double
            zoom_level =  zoomDict!["zoom_level"] as? Double
        }
        if zoomX == nil || zoomY == nil {
            zoomX = 5.0
            zoomY = 5.0
        }

        let region = WSIMapSDKRegionMake(locationCoordinate, zoom_level)
                      maxMap?.wsiSDK.setMapRegion(region, animated: false)
        maxMap?.checkedLoactionPermission(cordinates: coordinate)

        if maxMap?.layerDict == nil {
            if timer == nil {
                self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(LiveMapViewController.loadActiveLayer), userInfo: nil, repeats: true)
            }
        } else {
            self.loadActiveLayer()
        }
    }

    @objc func loadActiveLayer() {
        // Layers
        maxMap?.closeCallout()
        if self.isLocalRadar {
            if self.mapDict!["future_loop"] as? Bool ?? false {
                let shouldActivateLoop = self.mapDict!["future_loop"]as? Bool ?? false
                if shouldActivateLoop {
                    maxMap?.wsiSDK.setLayerDataState(WSIMapSDKLayerDataState.futureOnly)
                }
            } else {
                maxMap?.wsiSDK.setLayerDataState(WSIMapSDKLayerDataState.pastOnly)
            }
        }
        if maxMap?.layerDict != nil {
            timer?.invalidate()
            var layer = self.mapDict?["layer"] as? String ?? ""
            var updatedLayer: AnyHashable?
            if layer != "" {
                let mappingDictKeys = (maxMap!.wsiLayersMappingDict as NSDictionary).allKeys as? [String]
                if mappingDictKeys!.contains(layer) {
                    layer = maxMap?.wsiLayersMappingDict[layer] as? String ?? ""
                }
                updatedLayer = AnyHashable(layer)
                if updatedLayer != nil {

                    let mapObj = maxMap?.layerDict![layer] as? WSIMapSDKMapObject
                    maxMap?.wsiSDK.setActiveRasterLayer(mapObj)
                }
                self.isLayerActive = true

                if self.isLocalRadar {
                    self.addLayersMenuButton()
                }
            } else {
                maxMap?.wsiSDK.setActiveRasterLayer(nil)
                self.isLayerActive = false

                if self.isLocalRadar {
                    self.addLayersMenuButton()
                }
            }
            // Overlays
            var overlays: [String]
            overlays = self.mapDict?["overlays"] as? [String] ?? []
            if overlays != nil {
                for overlayName in overlays {
                    let overlayNameStr = overlayName

                    if maxMap?.wsiLayersMappingDict != nil {
                        let mappingDictKeys = (maxMap!.wsiLayersMappingDict as NSDictionary).allKeys as? [String]
                        if mappingDictKeys!.contains(overlayNameStr) {
                            let newOverlay = maxMap?.wsiLayersMappingDict[overlayNameStr] as? String
                            if newOverlay != nil {
                                overlays.remove(at: (overlays.firstIndex(of: overlayName))!)
                                overlays.append(newOverlay!)
                            }
                        }
                    }
                }
            }
            if let overlaysList = maxMap?.overlayList {
                for overlay in overlaysList {
                    if overlays != nil {
                        if overlays.contains((overlay as! WSIMapSDKMapObject).getLayerID()) {
                            if (overlay as! WSIMapSDKMapObject).getLayerID() == "wsi_OverlayLightning" {
                                let mapCoordinates = maxMap?.wsiSDK.getMapCenterCoordinate()
                                overlay.setClipRegionLocation(mapCoordinates!, radiusMiles: 100.0)
                            }
                            maxMap?.wsiSDK.setStateForOverlay(overlay as! WSIMapSDKMapObject, active: true)
                        } else {
                            maxMap?.wsiSDK.setStateForOverlay(overlay as! WSIMapSDKMapObject, active: false)
                        }
                    } else {
                        maxMap?.wsiSDK.setStateForOverlay(overlay as! WSIMapSDKMapObject, active: true)
                    }
                }
            }
            if isLocalRadar {
//                Alerts

            let mapObject = self.maxMap?.wsiSDK.getOverlayForLayerID("wsi_WeatherAlertsAll")
            let alertArray = (maxMap!.wsiAlertMappingDict as NSDictionary).allKeys as? [String] ?? []

                for alertCategory in alertArray {
                    if overlays.count > 0 {
                        if overlays.contains(alertCategory) {
                            let alert =  maxMap?.wsiAlertMappingDict[alertCategory]
                            maxMap?.wsiSDK.enableAlertCategory(alert as! String)
                            if !(mapObject?.isActive())! {
                                maxMap?.wsiSDK.setStateForOverlay(mapObject!, active: true)
                            }
                        } else {
                            let alert =  maxMap?.wsiAlertMappingDict[alertCategory]
                            maxMap?.wsiSDK.enableAlertCategory(alert as! String)
                            maxMap?.wsiSDK.disableAlertCategory(alert as! String)
                            if !(mapObject?.isActive())! {
                                maxMap?.wsiSDK.setStateForOverlay(mapObject!, active: true)
                            }
                        }
                    }
                }
            }

            let tranparency = self.mapDict?["transparency"] as? UInt
            if tranparency != nil {
                maxMap?.wsiSDK.setTransparencyPercentForActiveRasterLayer(tranparency!)
            }
            if self.mapDict?["loop"] != nil {
                let shouldActivateLoop: Bool? = self.mapDict?["loop"] as? Bool
                if shouldActivateLoop == true {
                    maxMap?.wsiSDK.setIsLooping(true)  // HAPP-650 commenting it for added slider
                    self.isLoopActive = true
                } else {
                    self.isLoopActive = false
                    maxMap?.wsiSDK.setIsLooping(false)  // HAPP-650 commenting it for added slider
                }
            } else if self.mapDict!["future_loop"] as? Bool ?? false {
                    maxMap?.wsiSDK.setLayerDataState(WSIMapSDKLayerDataState.futureOnly)
                maxMap?.wsiSDK.setIsLooping(true)  // HAPP-650 commenting it for added slider
                self.isLoopActive = true
            } else {
                maxMap?.wsiSDK.setIsLooping(false)  // HAPP-650 commenting it for added slider
                maxMap?.wsiSDK.setLayerDataState(WSIMapSDKLayerDataState.pastOnly)
                self.isLoopActive = false
            }
        }
    }

    @objc func didDragMap(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: { [weak self] () -> Void in
                if let strongSelf = self {
                    var frame = strongSelf.timestampView.frame
                    frame.origin.y = UIApplication.shared.statusBarHeight
                    strongSelf.timestampView.frame = frame
                }
            }, completion: { [weak self] (_: Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.timestampView.isHidden = true
                    strongSelf.updateSlider()  // HAPP-650
                    if(strongSelf.isLoopActive) {
                        if((strongSelf.maxMap?.wsiSDK) != nil) {
                            strongSelf.maxMap?.wsiSDK.setIsLooping(true)
                        }
                    }
                }
            })
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func setLayerTime(_ layerTime: Date) {
        DispatchQueue.main.async {
            if self.isLayerActive && self.isLoopActive {  // HAPP-650 commenting it for added slider
                if self.isLayerActive {
                    let localTimeString = self.getFormattedTime(layerTime)
                    self.activeLayerTime.text = localTimeString
                    self.timeLable.text = localTimeString
                    self.displayTimeStamp()
                    self.updateSliderAuto()
                    self.setStartAndEndTime()
                } else {
                    self.activeLayerTime.text = ""
                    self.timeLable.text = ""
                    self.startTimeLabel.text = ""
                    self.endtimeLabel.text = ""
                }
            }
        }
    }
    func setStartAndEndTime() {
        let info = self.maxMap?.wsiSDK.getActiveRasterLayerFrameInfo()
        
        if info != nil {
            let startTime = info!["LoopingTimeStart"] ?? "0"
            let startTimedate = Date(timeIntervalSince1970: (Double(startTime) ?? 0))
            
            let localStartTimeString = self.getFormattedTime(startTimedate)
            self.startTimeLabel.text = localStartTimeString
            
            if localStartTimeString?.count == 8 {
                self.timeslider.frame = CGRect(x: self.startTimeLabel.frame.origin.x + self.startTimeLabel.frame.size.width, y: (IS_IPAD ? 10:7.5), width: self.sliderBgView.frame.size.width - self.timeLable.frame.width - self.startTimeLabel.frame.width - (IS_IPAD ? 60:40) - 27 - 5 , height: (IS_IPAD ? 20:15))
            } else {
                self.timeslider.frame = CGRect(x: self.startTimeLabel.frame.origin.x + self.startTimeLabel.frame.size.width  - 5, y: (IS_IPAD ? 10:7.5), width: self.sliderBgView.frame.size.width - self.timeLable.frame.width - self.startTimeLabel.frame.width - (IS_IPAD ? 60:40) - 27 , height: (IS_IPAD ? 20:15))
            }
            
            let loopingEndTime = info!["LoopingTimeEnd"] ?? "0"
            let loopingEndDate = Date(timeIntervalSince1970: (Double(loopingEndTime) ?? 0))
            
            let localEndTimeString = self.getFormattedTime(loopingEndDate)
            self.endtimeLabel.text = localEndTimeString
        }
        
    }
    func updateSliderAuto() {
        if(isPlaying) {
            if let info = self.maxMap?.wsiSDK.getActiveRasterLayerFrameInfo() {
                let frameOffsetStringValue : String = info["FrameOffset"] ?? "0"
                let frameoffset : Double = Double(frameOffsetStringValue) ?? 0
                self.timeslider.setValue(Float(frameoffset), animated: true)
            }
        }
    }

    func getFormattedTime(_ layerTime: Date?) -> String? {
        if layerTime == nil {
            return nil
        }

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.locale = NSLocale.current
        dateFormatterGet.dateFormat = "h:mm a"

        let formattedTime = dateFormatterGet.string(from: layerTime!)
        return formattedTime
    }

    func displayTimeStamp() {
        if self.timestampView.isHidden && self.isLocalRadar {
            self.timestampView.isHidden = true
            var frame = self.timestampView.frame
            frame.origin.x = (self.view.frame.size.width - frame.size.width)/2
            let statusBarHeight = UIApplication.shared.statusBarHeight
            frame.origin.y = UIApplication.shared.statusBarHeight
            self.timestampView.frame = frame
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {[weak self] () -> Void in
                if let strongSelf = self {
                    var frame = strongSelf.timestampView.frame
                    if self!.isLocalRadar && self!.legendBackgroundView.isHidden == false {
                        frame.origin.y = self!.legendBackgroundView.frame.origin.y + self!.legendBackgroundView.frame.size.height - 10
                    } else {
                        frame.origin.y = statusBarHeight+navigationBarHeight - 10
                    }
                    strongSelf.timestampView.frame = frame
                }
            }, completion: {(_: Bool) -> Void in
            })
        }
    }

    func updateLayerimageview() {
        // Legend
        if (self.mapDict!["legend_name"]) != nil {

            self.legendBackgroundView.isHidden = false
            self.legendBackgroundView.backgroundColor = AppDefaults.colorWithHexValue(kWebViewControlsBgColor)
            var frame = self.legendBackgroundView.frame
            let statusBarHeight = UIApplication.shared.statusBarHeight + navigationBarHeight
            frame.origin.y = statusBarHeight
            frame.origin.x = 0
            frame.size.width = self.view.frame.size.width
            frame.size.height = 30
            self.legendBackgroundView.frame = frame
            let legendImage = UIImage.init(imageLiteralResourceName: self.mapDict!["legend_name"] as? String ?? "")
            self.legendImageView.frame.size.height = 30
            if IS_IPAD {
                self.legendImageView.frame.size.width = 500
                self.legendImageView.frame.origin.x = (self.view.frame.size.width - 500)/2
                self.legendImageView.contentMode = .scaleAspectFill
            } else {
                self.legendImageView.frame.size.width = self.view.frame.size.width
                self.legendImageView.frame.origin.x = 0
            }
            self.legendImageView.image = legendImage
            self.timestampView.isHidden = true

            var maxMApFrame = self.maxMap?.view.frame
            maxMApFrame?.origin.y = 20
            self.maxMap?.view.frame = maxMApFrame!
        } else {
            var maxMApFrame = self.maxMap?.view.frame
            maxMApFrame?.origin.y = 0
            self.maxMap?.view.frame = maxMApFrame!

            self.legendBackgroundView.isHidden = true
            self.timestampView.isHidden = true
            
            self.layerButton.frame = CGRect.init(x: (self.sliderBackgroundView.frame.origin.x + self.sliderBackgroundView.frame.width) - (IS_IPAD ? 160 : 130), y: self.legendBackgroundView.frame.origin.y + 30, width: (IS_IPAD ? 150 : 120), height: (IS_IPAD ? 40 : 30))
          
        }
        self.updateSlider() // HAPP-650 commenting it for added slider
        var isActivateLoop = false
        if self.mapDict?["loop"] != nil {
            let shouldActivateLoop: Bool? = self.mapDict?["loop"] as? Bool
            if shouldActivateLoop == true {
                isActivateLoop = true
            } else {
                isActivateLoop = false
            }
        } else if self.mapDict!["future_loop"] as? Bool ?? false {
            isActivateLoop = true
        } else {
            isActivateLoop = false
        }
        
        if(isActivateLoop) {
            self.playPauseButton.isUserInteractionEnabled = true
            self.timeslider.isUserInteractionEnabled = true
            self.playPauseButton.isEnabled = true
            self.timeslider.isEnabled = true
            self.sliderBackgroundView.backgroundColor =  .clear
            let image = UIImage(named: "pause")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            
            self.playPauseButton.setImage(image, for: .normal)
        } else {
            self.playPauseButton.isUserInteractionEnabled = false
            self.timeslider.isUserInteractionEnabled = false
            self.playPauseButton.isEnabled = false
            self.timeslider.isEnabled = false
            let image = UIImage(named: "play")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            
            self.playPauseButton.setImage(image, for: .normal)
        }

    }

    func addLayersMenuButton() {
        self.layerButton.removeFromSuperview()
        self.sliderBackgroundView.removeFromSuperview()
        self.sliderBackgroundView.frame = CGRect.init(x: (IS_IPAD ? 80:10), y: self.backgroundView.frame.size.height - (IS_IPAD ? 90:60), width: self.view.frame.size.width - (IS_IPAD ? 160:20), height: (IS_IPAD ? 80:60))
        self.sliderBackgroundView.backgroundColor = .clear
        
        self.sliderBackgroundView.layer.cornerRadius = self.sliderBackgroundView.frame.size.height/2
        self.sliderBackgroundView.layer.shadowColor = UIColor.black.cgColor
        self.sliderBackgroundView.layer.shadowOpacity = 0.7
        self.sliderBackgroundView.layer.shadowRadius = 5.0
        self.sliderBackgroundView.layer.masksToBounds = false
        self.view.addSubview(self.sliderBackgroundView)
        self.view.bringSubviewToFront(self.sliderBackgroundView)
        
        let yPosition = UIApplication.shared.statusBarHeight + navigationBarHeight + 30 + 30 // 30 for legendBackgroundView, 30 for spacing
        print(yPosition)
        
        self.layerButton.frame = CGRect.init(x: (self.sliderBackgroundView.frame.origin.x + self.sliderBackgroundView.frame.width) - (IS_IPAD ? 160 : 130), y: yPosition, width: (IS_IPAD ? 150 : 120), height: (IS_IPAD ? 40 : 30))
        self.layerButton .addTarget(self, action: #selector(showLayerController), for: UIControl.Event.touchUpInside)
        self.layerButton.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        self.layerButton.setTitleColor(borderColor, for: .normal)
        self.layerButton.setTitle("CUSTOMIZE MAP", for: .normal)
        self.layerButton.titleLabel?.font =  UIFont(name: kHurricaneFont_Regular, size: (IS_IPAD ? 16 : 14))
        self.layerButton.layer.cornerRadius = 5.0
        self.view.addSubview(self.layerButton)
        self.PlayPauseButtonDesign()
        self.updateLayerButtonFrame()
        self.designSlider()
        self.updateSlider()
    }
    func PlayPauseButtonDesign() {
        isPlaying = true
        self.playPauseButtonBgView = UIView(frame: CGRect(x: 0, y: 0, width:(IS_IPAD ? 80 : 60), height: (IS_IPAD ? 80 : 60)))
        self.playPauseButtonBgView.backgroundColor = backgroundColor
        self.playPauseButtonBgView.layer.borderColor = borderColor.cgColor
        self.playPauseButtonBgView.layer.borderWidth = 3.0
        self.playPauseButtonBgView.layer.cornerRadius = playPauseButtonBgView.frame.size.width/2
        self.sliderBackgroundView.addSubview(self.playPauseButtonBgView)
        
        self.playPauseButton.frame = CGRect.init(x: 10, y: 10, width: (self.playPauseButtonBgView.frame.width - 20), height: (self.playPauseButtonBgView.frame.width - 20))
        self.playPauseButton .addTarget(self, action: #selector(PlayPauseBtnClicked), for: UIControl.Event.touchUpInside)
        self.playPauseButton.backgroundColor = borderColor
        if #available(iOS 13.0, *) {
            let image = UIImage(named: "pause")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            
            self.playPauseButton.setImage(image, for: .normal)
        }
        self.playPauseButton.layer.cornerRadius = self.playPauseButton.frame.size.width/2
        playPauseButtonBgView.addSubview(self.playPauseButton)
        
    }
    func designSlider() // HAPP-650
    {
        self.timeslider.removeFromSuperview()
        self.timeLable.removeFromSuperview()
        self.startTimeLabel.removeFromSuperview()
        self.endtimeLabel.removeFromSuperview()
        self.sliderBgView.removeFromSuperview()
        self.sliderBgBorderView.removeFromSuperview()
        
        self.sliderBgBorderView = UIView(frame: CGRect(x: self.playPauseButtonBgView.frame.origin.x + self.playPauseButtonBgView.frame.width - 7, y: (self.sliderBackgroundView.frame.height - (IS_IPAD ? 46:36)) / 2, width: self.sliderBackgroundView.frame.width-self.playPauseButtonBgView.frame.width, height: (IS_IPAD ? 46:36)))
        self.sliderBgBorderView.backgroundColor = borderColor
        self.sliderBgBorderView.layer.cornerRadius = sliderBgBorderView.frame.height / 2
        self.sliderBgBorderView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        self.sliderBackgroundView.addSubview(self.sliderBgBorderView)
        
        self.sliderBgView = UIView(frame: CGRect(x: self.playPauseButtonBgView.frame.origin.x + self.playPauseButtonBgView.frame.width - 10, y: (self.sliderBackgroundView.frame.height - (IS_IPAD ? 40:30)) / 2, width: self.sliderBackgroundView.frame.width-self.playPauseButtonBgView.frame.width, height: (IS_IPAD ? 40:30)))
        self.sliderBgView.backgroundColor = backgroundColor
        self.sliderBgView.layer.cornerRadius = self.sliderBgView.frame.height / 2
        self.sliderBgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        self.sliderBackgroundView.addSubview(self.sliderBgView)
        
        self.timeLable = UILabel(frame: CGRect(x: 10, y: 0, width: (IS_IPAD ? 70:60), height: (IS_IPAD ? 40:30)))
        self.timeLable.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 16 : 14))
        self.timeLable.textColor = .white
        self.sliderBgView.addSubview(self.timeLable)
        
        let borderLbl = UILabel(frame: CGRect(x: self.timeLable.frame.width + self.timeLable.frame.origin.x, y: 0, width: 3, height: self.sliderBgView.frame.height))
        borderLbl.backgroundColor = borderColor
        self.sliderBgView.addSubview(borderLbl)
        
        self.startTimeLabel = UILabel(frame: CGRect(x: borderLbl.frame.width + borderLbl.frame.origin.x + 5, y: 0, width: (IS_IPAD ? 60:50), height: (IS_IPAD ? 40:30)))
        self.startTimeLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 14 : 12))
        self.startTimeLabel.textColor = .white
        self.sliderBgView.addSubview(self.startTimeLabel)
        
        self.timeslider = UISlider(frame:CGRect(x: self.startTimeLabel.frame.origin.x + self.startTimeLabel.frame.size.width  - 5, y: (IS_IPAD ? 10:7.5), width: self.sliderBgView.frame.size.width - self.timeLable.frame.width - self.startTimeLabel.frame.width - (IS_IPAD ? 60:30) - 27 , height: (IS_IPAD ? 20:15)))
        self.timeslider.minimumTrackTintColor = borderColor
        self.timeslider.maximumTrackTintColor = .white
        let image = UIImage(named: "slider_Thumb.png")
        self.timeslider.setThumbImage(image, for: .normal)
        self.sliderBgView.addSubview(self.timeslider)
        self.timeslider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnSlider(_:)))
        self.tapGesture.numberOfTapsRequired = 1
        self.tapGesture.delegate = self
        self.timeslider.addGestureRecognizer(self.tapGesture)
        
        self.endtimeLabel = UILabel(frame: CGRect(x: timeslider.frame.width + timeslider.frame.origin.x - 5, y: 0, width: (IS_IPAD ? 60:50), height: (IS_IPAD ? 40:30)))
        self.endtimeLabel.font = UIFont(name: kHurricaneFont_SemiBold, size: (IS_IPAD ? 14 : 12))
        self.endtimeLabel.textColor = .white
        self.sliderBgView.addSubview(self.endtimeLabel)
        
    }
    @objc func tappedOnSlider(_ sender: UITapGestureRecognizer) {
        self.pauseLooping(time: 0)
        isPlaying = false
    }
    func updateSlider()  // HAPP-650
    {
        if(maxMap?.wsiSDK != nil) {
            if(maxMap?.wsiSDK.getLayerDataState() == WSIMapSDKLayerDataState.futureOnly) {
                self.timeslider.minimumValue = 0.0
                self.timeslider.maximumValue = 1.0
                self.timeslider.setValue(0, animated: false)
            } else if(maxMap?.wsiSDK.getLayerDataState() == WSIMapSDKLayerDataState.pastOnly) {
                self.timeslider.minimumValue = -1.0
                self.timeslider.maximumValue = 0.0
                self.timeslider.setValue(-1, animated: false)
            } else if(maxMap?.wsiSDK.getLayerDataState() == WSIMapSDKLayerDataState.pastAndFuture) {
                self.timeslider.minimumValue = -1.0
                self.timeslider.maximumValue = 1.0
                self.timeslider.setValue(-1, animated: false)
            }
        }
    }
    
    @objc func sliderValueDidChange(_ sender:UISlider!) // HAPP-650
    {
        if(isPlaying) {
            self.PlayPauseBtnClicked()
        }
        print("Slider value changed = ",Double(sender.value))
        maxMap?.wsiSDK.setLayerDataOffset(Double(sender.value))
    }
    
    func updateLayerButtonFrame() {
        var bottomPadding = AppDefaults.getBottomPadding()
        print("bottomPadding =",bottomPadding)
        if(bottomPadding == 0) {
            bottomPadding = 70
        } else {
            if(self.isBannerAdReceived == false) {
                bottomPadding = 60
            } else {
                bottomPadding = 45
            }
        }
        // HAPP-650
        if IS_IPAD {
            self.sliderBackgroundView.frame = CGRect.init(x: 40, y: self.backgroundView.frame.size.height - 90, width: self.view.frame.size.width - 80, height: 80)
        } else {
            self.sliderBackgroundView.frame = CGRect.init(x: 10, y: self.backgroundView.frame.size.height - bottomPadding, width: self.view.frame.size.width - 20, height: 60)
        }
    }
    @objc func PlayPauseBtnClicked() {
        if(isPlaying) {
            self.pauseLooping(time: 0)
            isPlaying = false
        } else {
            self.PlayLooping()
            isPlaying = true
        }
    }
    func pauseLooping(time: CGFloat) {
        maxMap?.wsiSDK.pauseLooping(time) // Used for Pause looping
        let image = UIImage(named: "play")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        self.playPauseButton.setImage(image, for: .normal)
    }
    func PlayLooping() {
        maxMap?.wsiSDK.setIsLooping(true)
        let image = UIImage(named: "pause")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        self.playPauseButton.setImage(image, for: .normal)
    }

    @objc func  showLayerController() {
        if(AppDefaults.checkInternetConnection()) {
            let vc = RadarLayerViewController(nibName: "RadarLayerViewController", bundle: nil)
            vc.selectedRadarLayer = self.mapDict?["title"] as? String ?? "Precipitation (Default)"
            vc.modalPresentationStyle = .overFullScreen
            let statusBarHeight = UIApplication.shared.statusBarHeight + navigationBarHeight
            vc.tableViewtopMargin = statusBarHeight
            present(vc, animated: true, completion: nil)
        } else {
            self.handleNetworkError(nil, statusCode: NSURLErrorNotConnectedToInternet)
        }
    }

    @objc func updateActiveLayers(notification: NSNotification) {

        self.mapDict = notification.object as? [AnyHashable: Any]
        self.updateLayers(self.mapDict ?? [:])
    }

    func updateLayers(_ userData: [AnyHashable: Any]) {
        self.mapDict = userData
        self.loadActiveLayer()
        self.updateTitleView()
        if self.isLocalRadar {
            self.updateLayerimageview()
        }
    }

    func updateTitleView() {
        self.screenName = self.mapDict?["title"] as? String
        if self.screenName == "Precipitation (Default)" {
            self.screenName = "Precipitation"
        }
        displayTitle = self.screenName
        if displayTitle != nil {
            AppDefaults.setNavigationBarTitle(displayTitle!, self.view)
        }
    }
}
