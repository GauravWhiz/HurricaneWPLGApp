//
//  MaxMapViewController.swift
//  Hurricane
//
//  Created by Swati Verma on 02/09/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import UIKit
import MapKit
protocol MaxMapViewDelegate: AnyObject {
    func setLayerTime(_ layerTime: Date)
}

class MaxMapViewController: UIViewController, WSIMapSDKDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    static let sharedInstance = MaxMapViewController()
    var locationManager: CLLocationManager = CLLocationManager()
    var wsiSDK: WSIMapSDK!
    var layerDict: [AnyHashable: Any]?
    var categoryDict = [String: AnyObject]()
    var overlayList = [AnyObject]()
    var featuresList = [AnyObject]()
    var wsiLayersMappingDict = [AnyHashable: Any]()
    var wsiAlertMappingDict = [AnyHashable: Any]()

    var gestureHandler: WSIMapDemoGestureHandler?
    var calloutHandler: WSIMapDemoCalloutHandler?
    weak var delegate: MaxMapViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.

        self.createWsiLayersMappingDict()
        self.initMap()
        print(WSIMapSDK.getVersionString())
    }

    override func viewWillDisappear(_ animated: Bool) {
        wsiSDK.removeViewAnnotation(withUniqueID: "CurrentLocAnnotation")
    }
    func initMap() {
        if wsiSDK == nil {

            let sdkKey = "cd1df15e-566b-507a-2839-fdb398cd4f07"

            self.wsiSDK = WSIMapSDK.sharedInstance() as? WSIMapSDK

            // instantiate and initialize WSIMapSDK object
            self.wsiSDK = WSIMapSDK.createInstance(with: self, mapStyle: WSIMapSDKMapStyle.b2BSatelliteLightWithLabels, clientKey: sdkKey)
       
            if self.wsiSDK != nil {
                self.wsiSDK!.mapView.frame = self.view.frame

                // place map view in main view
                self.view.addSubview(self.wsiSDK!.mapView)

                self.calloutHandler = WSIMapDemoCalloutHandler.init(mapView: wsiSDK.mapView)
                self.gestureHandler = WSIMapDemoGestureHandler.init(calloutHandler: calloutHandler)
                wsiSDK.appGestureDelegate = self.gestureHandler
            }

        }
    }

    func updateFrame(_ frame: CGRect) {
        var mapFrame = self.wsiSDK?.mapView.frame
        if mapFrame != nil {
            mapFrame!.size.height = frame.size.height
            mapFrame!.size.width = frame.size.width
            self.wsiSDK?.mapView.frame = mapFrame!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createWsiLayersMappingDict() {
        self.wsiLayersMappingDict = [
                                     "wsi_LayerRadar": "wsi_LayerRadar",
                                     "wsi_LayerWindSpeedLegacy": "wsi_LayerWindSpeed",
                                     "wsi_LayerSnowCover": "wsi_LayerSnowCover",
                                     "wsi_LayerRoadWeather": "wsi_LayerRoadWeather",
                                     "wsi_LayerSatellite": "wsi_LayerSatellite",
                                     "wsi_LayerTemperature": "wsi_LayerTemperature",
                                     "wsi_LayerRadarOverSatellite": "wsi_LayerRadarOverSatellite",
/// *  HAPP-494*/                       "wsisdk_LayerWaterTemperature": "wsi_LayerWaterTemperature", //Removed from Latest SDK V5.1.009
                                     "wsi_LayerWaterTemperature": "wsi_LayerWaterTemperature",
                                     "wsi_OverlayTropicalTracks": "wsi_OverlayTropicalTracks",
                                     "wsi_LayerHDSatelliteNAmerica": "wsi_LayerSatellite",
                                     "wsi_LayerHDSatelliteTropics": "wsi_LayerRadar",
                                     "wsi_LayerRadarConusAndHDSatelliteNAmerica": "wsi_LayerRadarOverSatellite",
                                     "wsi_LayerTemperatureConus": "wsi_LayerSurfaceTemperatureLand",
                                     "wsi_LayerSnowCoverConus": "wsi_LayerSnowfall",
                                     "wsi_LayerRadarConus": "wsi_LayerRadar",
                                     "wsi_LayerTrafficFlowAndRadarConus": "wsi_LayerTrafficFlowAndRadar",
                                     "wsi_WeatherAlertsFlood": "wsi_WeatherAlertsFlood",
                                     "wsi_OverlayStormTracks": "wsi_OverlayStormTracks",
                                     "wsi_OverlayEarthquakes": "wsi_OverlayEarthquakes",
                                     "wsi_WeatherAlertsSevere": "wsi_WeatherAlertsSevere"
            ]

        self.wsiAlertMappingDict = [
                                     "wsi_WeatherAlertsSevere": "wsi_AlertCategorySevere",
                                    "wsi_WeatherAlertsTropical": "wsi_AlertCategoryTropical",
                                    "wsi_WeatherAlertsMarine": "wsi_AlertCategoryMarine",
                                    "wsi_WeatherAlertsFlood": "wsi_AlertCategoryFlood",
                                    "wsi_WeatherAlertsOther": "wsi_AlertCategoryOther",
                                    "wsi_WeatherAlertsWinter": "wsi_AlertCategoryWinter"
        ]
}

    func wsiMapSDKError(_ error: Error!) {
        print(error as Any)
    }
    public func wsiMapSDKCredentialsValidated() {
        self.requestForLayersList()
        self.requestForOverlaysList()
        self.requestForgetCategories()
    }

    func requestForLayersList() {
        self.layerDict = [AnyHashable: Any]()
   
        let rasterLayersList = wsiSDK!.getAvailableRasterLayers()
        print("Got layers list:")
        for layer in rasterLayersList! {
            print(layer.getLayerID())
            self.layerDict![layer.getLayerID()] = layer
        }
        print("Got layers list:\n\n\n\n")
    }
    func requestForOverlaysList() {
        self.overlayList = [AnyObject]()
        let overlays: [WSIMapSDKMapObject] = wsiSDK!.getAvailableOverlays()
        print("Got overlays list:")
        print(overlays.count)
        for mapObject in overlays {
             print(mapObject.getLayerID())
            self.overlayList.append(mapObject)
        }
         print("Got layers list:\n\n\n\n")
    }

    func requestForFeatureList() {
        self.featuresList = [AnyObject]()
        let features: [WSIMapSDKMapObject] = wsiSDK!.getAvailableFeatures()
        print("Got overlays list:")
        print(features.count)
        for mapObject in features {
             print(mapObject.getLayerID())
            self.featuresList.append(mapObject)
        }
         print("Got layers list:\n\n\n\n")
    }

    func requestForgetCategories() {
         self.categoryDict = [String: AnyObject]()
         let categories: [WSIMapSDKMapObject] = wsiSDK!.getAvailableAlerts()
         for category: Any in categories {
            print((category as! WSIMapSDKMapObject).getLayerID())
             self.categoryDict[(category as! WSIMapSDKMapObject).getLayerID()] = category as! WSIMapSDKMapObject
         }
     }

    func wsiMapSDKActiveRasterLayerFrameChanged() {
        let timeInterval: TimeInterval = self.wsiSDK.getActiveRasterLayerFrameTime()
        let date = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        self.delegate?.setLayerTime(date as Date)

    }
    // set annotation
    func setannotation(coordinates: CLLocationCoordinate2D) {
        self.wsiSDK.showViewBasedAnnotations()
        let view = UIView.init()
        view.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        view.layer.cornerRadius = 9
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.init(red: 46/255, green: 135/255, blue: 252/255, alpha: 1)

        wsiSDK.removeViewAnnotation(withUniqueID: "CurrentLocAnnotation")
        wsiSDK.addViewAnnotation(withUniqueID: "CurrentLocAnnotation", coordinate: coordinates, view: view)
    }
    // checked location permission
    func checkedLoactionPermission(cordinates: CLLocationCoordinate2D) {
        switch CLLocationManager.authorizationStatus() {
        case CLAuthorizationStatus.authorizedAlways:
            self.setannotation(coordinates: cordinates)
            break
        case CLAuthorizationStatus.authorizedWhenInUse:
            self.setannotation(coordinates: cordinates)

            break

        case CLAuthorizationStatus.denied, CLAuthorizationStatus.restricted, CLAuthorizationStatus.notDetermined:
            print("Location services denied by user")

            break
        @unknown default: break

        }
    }
    // Get users updated location
    func locationUpdated(latitude: Double, logitude: Double) {
        print(locationUpdated)
        if wsiSDK != nil {

            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: logitude)
            self.checkedLoactionPermission(cordinates: coordinate)
        }
    }
    func closeCallout() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SDKDemoCloseCalloutNotification"), object: nil)
    }
}
