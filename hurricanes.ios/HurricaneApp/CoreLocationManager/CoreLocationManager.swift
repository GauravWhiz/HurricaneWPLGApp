//
//  CoreLocationManager.swift
//  Hurricane
//
//  Created by Swati Verma on 31/08/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

class CoreLocationManager: NSObject, CLLocationManagerDelegate {
    var currentCoordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager
    let kLastLoggedLocation = "lastLoggedLocation"
    let kLocationDistanceFactor = 1000.00
    var maxMap: MaxMapViewController = MaxMapViewController.sharedInstance

    static let sharedInstance = CoreLocationManager()

    override init() {

        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func startUpdatingLocation() {
        // Check for iOS 8
        if self.locationManager.responds(to: #selector(self.locationManager.requestAlwaysAuthorization)) {
            self.locationManager.requestAlwaysAuthorization()
        }
        self.locationManager.startUpdatingLocation()
    }

    func getCurrentLocation() -> CLLocationCoordinate2D {
        switch CLLocationManager.authorizationStatus() {
        case CLAuthorizationStatus.authorizedAlways:
            self.currentCoordinate = self.locationManager.location?.coordinate
        case CLAuthorizationStatus.authorizedWhenInUse:
            self.currentCoordinate = self.locationManager.location?.coordinate
        case CLAuthorizationStatus.denied, CLAuthorizationStatus.restricted, CLAuthorizationStatus.notDetermined:
            print("Location services denied by user")
            self.setDefaultCordinates()
            break
        default: self.setDefaultCordinates()
            break
        }
        /* Get default location on simulator */
        if self.currentCoordinate == nil {
            self.setDefaultCordinates()
        }
        if self.currentCoordinate != nil {
            return self.currentCoordinate!
        } else {
            return CLLocationCoordinate2D()
        }
    }

    func setDefaultCordinates() {
        var coordinate = CLLocationCoordinate2D()

        let locationDict: NSDictionary? = (FirebaseRemoteConfig.sharedInstance().lookupConfig(byKey: kDefaultCoordinates)) as? NSDictionary

        if locationDict != nil {
            let defaultLat = (locationDict!.object(forKey: kDefaultLat)) as? Double
            let defaultLon = (locationDict!.object(forKey: kDefaultLon)) as? Double
            if defaultLat != nil && defaultLon != nil {
                coordinate.latitude = defaultLat!
                coordinate.longitude = defaultLon!
            }
            self.currentCoordinate = coordinate
        }

    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var coreLocationPermissionStatus: String
        switch status {
        case CLAuthorizationStatus.authorizedAlways:
            coreLocationPermissionStatus = kAllowed
        case CLAuthorizationStatus.authorizedWhenInUse:
            coreLocationPermissionStatus = kAllowed
        case CLAuthorizationStatus.denied:
            coreLocationPermissionStatus = kRejected
        case CLAuthorizationStatus.restricted:
            coreLocationPermissionStatus = kRejected
        case CLAuthorizationStatus.notDetermined:
            coreLocationPermissionStatus = kRejected
        @unknown default:
            coreLocationPermissionStatus = kRejected
        }
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        let params = GAIDictionaryBuilder.createEvent(withCategory: kGPSShared, action: coreLocationPermissionStatus, label: nil, value: nil).build() as [NSObject: AnyObject]
        tracker.send(params)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation? = locations.last
        let defaults = UserDefaults.standard

        if let currentLocation = location {
            if let locationDict: [AnyHashable: Any] = defaults.object(forKey: kLastLoggedLocation) as? [AnyHashable: Any] {
                if locationDict["latitude"] == nil || locationDict["longitude"] == nil {
                
                    saveCurrentLocationData(currentLocation)
                } else {
                    let latitude = CDouble((locationDict["latitude"] as! Double))
                    let longitude = CDouble(locationDict["longitude"] as! Double)
                    let lastLoggedLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let distance: CLLocationDistance = lastLoggedLocation.distance(from: currentLocation)
                    maxMap.locationUpdated(latitude: latitude, logitude: longitude)
                    if distance > kLocationDistanceFactor {
                    
                        saveCurrentLocationData(currentLocation)
                    }
                }
            }
        }
    }

    func saveCurrentLocationData(_ currentLocation: CLLocation) {
        let defaults = UserDefaults.standard
        let latitude = Double(currentLocation.coordinate.latitude)
        let longitude = Double(currentLocation.coordinate.longitude)
        let locationDict: [AnyHashable: Any] = [
            "latitude": latitude,
            "longitude": longitude
        ]

        defaults.set(locationDict, forKey: kLastLoggedLocation)
        defaults.synchronize()
    }
    
    func fetchLocationAuthorizationStatus() -> String {
        var coreLocationPermissionStatus: String
        
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case CLAuthorizationStatus.authorizedAlways:
            coreLocationPermissionStatus = "Always"
        case CLAuthorizationStatus.authorizedWhenInUse:
            coreLocationPermissionStatus = "While Using The App"
        case CLAuthorizationStatus.denied:
            coreLocationPermissionStatus = "Denied"
        case CLAuthorizationStatus.restricted:
            coreLocationPermissionStatus = "Restricted"
        case CLAuthorizationStatus.notDetermined:
            coreLocationPermissionStatus = "Not Determined"
        @unknown default:
            coreLocationPermissionStatus = "Not Determined"
        }
        return coreLocationPermissionStatus
    }
}
