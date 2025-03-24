//
//  DataDownloadManager.swift
//  Hurricane
//
//  Created by Swati Verma on 12/10/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation
import Alamofire

let kNameKey = "name"
let kPagesKey = "pages"
let kTabsKey = "tabs"
let kNodesKey = "nodes"
let kSubNodeKey = "node"
let kImgSrc = "src"
let kLiveStreamKey = "livestream"
let kNotificationsKey = "notifications"
let kStormKey = "storms"
let kTropicKey = "tropics"
let kWatchAndWarningKey = "watcheswarnings"
let kHurricaneDataDownloaded = "HurricaneDataDownloaded"
let kDataDownLoadFailed = "DataDownLoadFailed"
let kStationCallLettersKey = "station_callletters"
let kPrioroty1Key = "priority1"

@objc protocol DataDownloadManagerDelegate: AnyObject {
    func didSuccess(toSaveData isSuccess: Bool)
}

@objc protocol GetWeatherDataDelegate: AnyObject {
    @objc optional func didGetWeatherData(notification:Notification)
}

class DataDownloadManager: NSObject {
    weak var errorHandler: ErrorHandler?
    weak var delegate: DataDownloadManagerDelegate?
    weak var weatherDataDelegate: GetWeatherDataDelegate?
    var managedObjectContext: NSManagedObjectContext!

    static var SharedImagesPath: String?
    static let sharedInstance = DataDownloadManager()

    var forecastVideoDic: NSDictionary!
    var liveStreamArray: [[String: Any]]!
    var stationHeadlinesArray: NSArray!
    var sailthruDeviceId: String!
    private var stationCallLetters:String?

    func downloadAllData() {
        
        AF.request(AppDefaults.getAPIURL()).response { response in
           
            switch response.result {
                    case .success:
                                    do {
                                        let responseObject = try JSONSerialization.jsonObject(with: response.value!!, options: []) as? [String : Any]
                                        if responseObject != nil {
                                            self.delegate?.didSuccess(toSaveData: self.saveParsedJson(responseObject as? NSDictionary))
                                        }
                                        
                                    } catch {
                                        print("errorMsg")
                                    }
                                    
                    case let .failure(error):
                                   
                                    self.errorHandler?.handleNetworkError(error as NSError?, statusCode: nil)
                
                                    if (self.delegate != nil) {
                                        
                                        self.delegate?.didSuccess(toSaveData: false)
                                        
                                    }
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDataDownLoadFailed), object: nil)
                                    print(error)
            }

            self.downloadLivestreamData()
        }
     
    }
    
  /*  func downloadWeatherNotificationData() {
        let manager = AFHTTPRequestOperationManager()
        manager.get(
            "https://s3.amazonaws.com/notifications-api/weather/KPRC.json",
            parameters: nil,
            success: { (_: AFHTTPRequestOperation?, responseObject: Any?) in
                let dataDictionary = responseObject as? NSDictionary
                
                let notificationsDic = dataDictionary!["notification"] as? [String: Any]
                var notificationsArray = [Any]()
                notificationsArray.append(notificationsDic)
                
                
               // let notificationsArray = (dataDictionary!["notification"] as? [[String: Any]])
                self.saveNotificationsData(notificationsArray)
                let notification = DataDownloadManager.sharedInstance.getNotificationsData()?.last
                if notification !=  nil {
                    self.weatherDataDelegate?.didGetWeatherData!(notification: notification as! Notification)
                }
                

        },
            failure: { (_: AFHTTPRequestOperation?, error: Error?) in
                print("Error: \(String(describing: error?.localizedDescription))")

        }

    }*/

    func downloadLivestreamData() {
        
     /* 
        // For test livestream url
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            if let path = Bundle.main.path(forResource: "livestreamtest", ofType: "json") {
                do {
                      let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                      let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                      if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                            // do stuff
                          self.liveStreamArray = jsonResult["assets"] as? [[String: Any]]

                          if self.liveStreamArray.count > 1 {
                              // sorting
                              let dateFormatter = DateFormatter()
                              dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"

                              for i in 0...self.liveStreamArray.count-1 {
                                  let dic = self.liveStreamArray[i]
                                  let updatedDate = dateFormatter.date(from: dic["updated"] as! String)

                                  if updatedDate != nil {

                                      if (i+1) <= self.liveStreamArray.count-1 {
                                          for j in (i+1)...self.liveStreamArray.count-1 {

                                              let dic1 = self.liveStreamArray[j]
                                              let updatedDate1 = dateFormatter.date(from: dic1["updated"] as! String)

                                              if updatedDate1 != nil {
                                                  if updatedDate?.compare(updatedDate1!) == ComparisonResult.orderedAscending {
                                                      self.liveStreamArray.swapAt(i, j)
                                                      break
                                                  }
                                              }

                                          }
                                      }

                                  }
                              }

                          }
                          
                          if self.liveStreamArray.count > 1 {
                                              self.liveStreamArray.removeLast()
                          }

                          if self.liveStreamArray.count > 0 {

                              NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kNotificationWXWorksDataLoad), object: nil, userInfo: nil)

                          }
                          
                      }
                  } catch {
                       // handle error
                  }
            }
            
            Timer.scheduledTimer(timeInterval: 0.50, target: self, selector: #selector(self.downloadFlavorStationHeadlinesData), userInfo: nil, repeats: false)
            
        }
        
       
        
        return
      */
        
        
        AF.request(AppDefaults.getLivestreamURL()).response { response in
            
            switch response.result {
                    case .success:
                                    do {
                                        let responseObject = try JSONSerialization.jsonObject(with: response.value!!, options: []) as? [String : Any]
                                        if responseObject != nil {
                                            let responseDict = responseObject as? NSDictionary
                                            
                                            self.liveStreamArray = responseDict!["assets"] as? [[String: Any]]

                                            if self.liveStreamArray.count > 1 {
                                                // sorting
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"

                                                for i in 0...self.liveStreamArray.count-1 {
                                                    let dic = self.liveStreamArray[i]
                                                    let updatedDate = dateFormatter.date(from: dic["updated"] as! String)

                                                    if updatedDate != nil {

                                                        if (i+1) <= self.liveStreamArray.count-1 {
                                                            for j in (i+1)...self.liveStreamArray.count-1 {

                                                                let dic1 = self.liveStreamArray[j]
                                                                let updatedDate1 = dateFormatter.date(from: dic1["updated"] as! String)

                                                                if updatedDate1 != nil {
                                                                    if updatedDate?.compare(updatedDate1!) == ComparisonResult.orderedAscending {
                                                                        self.liveStreamArray.swapAt(i, j)
                                                                        break
                                                                    }
                                                                }

                                                            }
                                                        }

                                                    }
                                                }

                                            }
                                            
                                            if self.liveStreamArray.count > 1 {
                                                                self.liveStreamArray.removeLast()
                                            }

                                            if self.liveStreamArray.count > 0 {

                                                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kNotificationWXWorksDataLoad), object: nil, userInfo: nil)

                                            }
                                        }
                                        
                                    } catch {
                                        print("errorMsg")
                                    }
                                    
                    case let .failure(error):
                print("Error: \(String(describing: error.localizedDescription))")
            }

            Timer.scheduledTimer(timeInterval: 0.50, target: self, selector: #selector(self.downloadFlavorStationHeadlinesData), userInfo: nil, repeats: false)

        }

    }

    @objc func downloadFlavorStationHeadlinesData() {
        
        AF.request(AppDefaults.getFlavorsStationHeadlinesURL()).response { response in
           
            switch response.result {
                    case .success:
                                    do {
                                        let responseObject = try JSONSerialization.jsonObject(with: response.value!!, options: []) as? NSArray
                                        if responseObject != nil {

                                            for objectsArray in responseObject! {
                                                self.stationHeadlinesArray = (objectsArray as! NSArray)

                                            }

                                        }
                                        
                                    } catch {
                                        print("errorMsg")
                                    }
                                    
                    case let .failure(error):
                                    print("Error: \(String(describing: error.localizedDescription))")
            }
        }

    }

    func downloadForacastVideoData() {
        
        AF.request(AppDefaults.getForacstVideoURL()).response { response in
           
            switch response.result {
                    case .success:
                                    do {
                                        let responseObject = try JSONSerialization.jsonObject(with: response.value!!, options: []) as? [String : Any]
                                        if responseObject != nil {
                                            let responseDict = responseObject as? NSDictionary

                                            let itemsArray = (responseDict!["items"] as? [[String: Any]])

                                            if itemsArray != nil {

                                                for itemDict in itemsArray! {
                                                  
                                                    let videosArray = (itemDict["videos"] as? [[String: Any]])

                                                    if videosArray != nil {
                                                        if videosArray!.count > 0 {
                                                            self.forecastVideoDic = itemDict as NSDictionary
                                                        }
                                                    }

                                                }

                                            }
                                        }
                                        
                                    } catch {
                                        print("errorMsg")
                                    }
                                    
                    case let .failure(error):
                                            print("Error: \(String(describing: error.localizedDescription))")
            }
        }
    }

    func saveParsedJson(_ dataDictionary: NSDictionary?) -> Bool {
        print("Saving data")
        /* Delete All Cache Images */
        var fileArray: [String]?
        do {
            fileArray = try FileManager.default.contentsOfDirectory(atPath: self.sharedCacheImagesPath())
        } catch let error {
            print("Error in fetching cached images:\(error.localizedDescription)" )
        }
        if fileArray != nil {
            for filename: String in fileArray! {
                let filePath = self.getPathForImage(filename)
                do {
                    try FileManager.default.removeItem(at: NSURL(string: filePath)! as URL)
                } catch let error {
                    print("Error in deleting image: \(error.localizedDescription)")
                }
            }
        }
        var success = false
        if dataDictionary != nil {
            self.managedObjectContext = DataManager.sharedInstance.mainObjectContext
            let liveStreamDictionary = (dataDictionary![kLiveStreamKey] as? [String: Any])
            let notificationsArray = (dataDictionary![kNotificationsKey] as? [Any])
            if let pageDictionary = (dataDictionary![kPagesKey] as? [String: Any]) {
                let stormArray = (dataDictionary![kStormKey] as? [Any])
                let tropicsDictionary = (pageDictionary[kTropicKey] as! [String: Any])
                let watchAndWarningDictionary = (pageDictionary[kWatchAndWarningKey] as! [String: Any])
                self.stationCallLetters = (dataDictionary![kStationCallLettersKey] as? String)
                
                success = self.saveLiveStreamData(liveStreamDictionary)
                success = self.saveNotificationsData(notificationsArray)
                success = self.saveStormData(stormArray)
                success = self.saveTropicWatchdata(tropicsDictionary)
                success = self.saveWatchAndWarningsData(watchAndWarningDictionary)
                if self.getNotificationsData() != nil && self.getNotificationsData()!.count > 0 {
                   // NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationTimeStart), object: nil)
                } else {
                   // NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationTimeStop), object: nil)
                }
            }
        }
        return success
    }

    func saveLiveStreamData(_ liveStreamDict: [AnyHashable: Any]?) -> Bool {
        var success = false
        success = self.deleteData(forEntity: kEntityLiveStream)
        if liveStreamDict == nil {
            return true
        }
        print("Saving LiveStream data")
        let liveStream = NSEntityDescription.insertNewObject(forEntityName: kEntityLiveStream, into: self.managedObjectContext!) as! LiveStream
        liveStream.text = (liveStreamDict!["text"] as? String)
        if let iosNode = (liveStreamDict!["ios"] as? [String: Any]) {
            liveStream.videoURL = iosNode["HLS"] as? String
        }
        success = true
        return success
    }

    func getLiveStreamData() -> [Any]? {
        if self.managedObjectContext == nil {
            return nil
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: kEntityLiveStream, in: self.managedObjectContext!)!
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "text", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var error: Error?
        var resultingData: [AnyObject]?
        do {
            resultingData = try self.managedObjectContext!.fetch(fetchRequest)
        } catch let error1 {
            error = error1
            print("Error in fetching entities \(String(describing: error))")
        }
        if resultingData == nil {
            print("Couldn't get object for entity : \(kEntityLiveStream)")
        }
        return resultingData
    }

    func saveNotificationsData(_ notificationsArray: [Any]?) -> Bool {
        if notificationsArray == nil || self.managedObjectContext == nil {
            return true
        }
        var success = false
        success = self.deleteData(forEntity: kEntityNotifications)
        print("Saving Notifications data")
        for (index, notificationParentDict) in notificationsArray!.enumerated() {
            if let notificationDict = notificationParentDict as? [AnyHashable: Any] {
                self.managedObjectContext = DataManager.sharedInstance.mainObjectContext
                let notification = NSEntityDescription.insertNewObject(forEntityName: kEntityNotifications, into: self.managedObjectContext!) as! Notification
                notification.index = index as NSNumber?
                notification.timesince = notificationDict["timesince"] as? String
                notification.idx = notificationDict["id"] as? String
                notification.text = notificationDict["text"] as? String
                notification.callleters = notificationDict["callleters"] as? String
                let isActive = notificationDict["active"] as? Bool
                if isActive != nil {
                    notification.active = NSNumber(value: isActive!)
                }

                notification.banner = (notificationDict["banner"] as? String)
                notification.title = (notificationDict["notification"] as? String)
                notification.met = (notificationDict["met"] as? String)
                notification.startTime = (notificationDict["start_time"] as? String)
                notification.endTime = (notificationDict["end_time"] as? String)
                let imageURL = (notificationDict["image"] as? String)
                if imageURL != nil {
                    let imagePath = String(format: "%@_%@", arguments: [notification.idx!, (imageURL! as NSString).lastPathComponent])
                    let imageNameWithPath = self.getPathForImage(imagePath)
                    notification.imageURL = imageURL
                    notification.imageNameWithPath = "\(imageNameWithPath)"
                }

                success = true
            }
        }
        return success
    }

    func getNotificationsData() -> [Any]? {
        if self.managedObjectContext == nil {
            return nil
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: kEntityNotifications, in: self.managedObjectContext!)!
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "text", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var error: Error?
        var resultingData: [AnyObject]?
        do {
            resultingData = try self.managedObjectContext!.fetch(fetchRequest)
        } catch let error1 {
            error = error1
            print("Error in fetching entities \(String(describing: error))")
        }
        if resultingData == nil {
            print("Couldn't get object for entity : \(kEntityNotifications)")
        }
        return resultingData
    }

    func saveStormData(_ stormArray: [Any]?) -> Bool {
        if stormArray == nil {
            return true
        }
        var success = false
        success = self.deleteData(forEntity: kEntityStormCenter)
        success = self.deleteData(forEntity: kEntityStormCenterDetail)
        print("Saving Storm Center data")
        for (index, stormDict) in stormArray!.enumerated() {
            let stormParentDict = stormDict as? [String: Any]
            if stormParentDict != nil {
                let stormCenter = NSEntityDescription.insertNewObject(forEntityName: kEntityStormCenter, into: self.managedObjectContext!) as! StormCenter
                stormCenter.index = index as NSNumber?
                stormCenter.fullName = (stormParentDict!["name"] as? String)
                stormCenter.stormName = (stormParentDict!["storm_name"] as? String)
                stormCenter.stormNum = stormParentDict!["storm_num"] as? NSNumber
                stormCenter.type = (stormParentDict!["type"] as? String)
                stormCenter.subhead = (stormParentDict!["subhead"] as? String)
                stormCenter.idx = (stormParentDict!["id"] as? String)
                stormCenter.discussionHtml = (stormParentDict!["discussion"] as? String)
                stormCenter.stormSurge = (stormParentDict!["storm_surge"] as? String)
                
                var priority = 2

                if self.stationCallLetters != nil {
                    let priorityArray = (stormParentDict![kPrioroty1Key] as? [Any])
                    
                    if priorityArray != nil {
                        
                        for callLetters: Any in priorityArray! {
                            if (callLetters as! String) == self.stationCallLetters {
                                priority = 1
                                break
                            }
                        }
                    }
                    
                }
                
                stormCenter.stormPriority = priority as NSNumber?
                
                let tabArray = (stormParentDict![kTabsKey] as? [Any])
                if tabArray != nil {
                    for (index, tabParentDictionary) in tabArray!.enumerated() {
                        let tabDictionary = tabParentDictionary as? [String: Any]
                        if tabDictionary != nil {
                            let nodesArray = (tabDictionary![kNodesKey] as? [Any])
                            let stormCenterDetail = NSEntityDescription.insertNewObject(forEntityName: kEntityStormCenterDetail, into: self.managedObjectContext!) as! StormCenterDetail
                            stormCenterDetail.index = index as NSNumber?
                            stormCenterDetail.name = (tabDictionary![kNameKey] as? String)
                            
                            if nodesArray != nil {
                                for nodesParentDictionary: Any in nodesArray! {
                                    let nodesDictionary = nodesParentDictionary as? [String: Any]
                                    if nodesDictionary != nil {
                                        let node = (nodesDictionary![kSubNodeKey] as? String)
                                        if node == "image" {
                                            let imageURL = (nodesDictionary!["src"] as? String)
                                            if imageURL != nil {
                                                let imagePath = String(format: "%@_%d_%@", arguments: [stormCenter.idx!, index, (imageURL! as NSString).lastPathComponent])
                                                let imageNameWithPath = self.getPathForImage(imagePath)
                                                stormCenterDetail.imageURL = imageURL
                                                stormCenterDetail.imageNameWithPath = "\(imageNameWithPath)"
                                            }
                                            
                                            let loopGifURL = (nodesDictionary!["loop_gif"] as? String)
                                            
                                            if loopGifURL != nil {
                                                stormCenterDetail.loop_gif = "\(loopGifURL!)"
//                                                self.downloadGIF(from: loopGifURL!, completion: { (downloadedURL) in
//                                                    stormCenterDetail.loop_gif = downloadedURL?.absoluteString
//                                                })
                                            }
                                            
                                        } else if node == "text" {
                                            stormCenterDetail.discussion = (nodesDictionary!["text"] as? String)
                                        } else if node == "data" {
                                            if let rowsArray = nodesDictionary!["rows"] as? [Any] {
                                                var rowArray = rowsArray[0] as! [Any]
                                                stormCenterDetail.status = rowArray[0] as? String
                                                rowArray = rowsArray[1] as! [Any]
                                                stormCenterDetail.windSpeedText = rowArray[0] as? String
                                                stormCenterDetail.windSpeedValue = rowArray[1] as? String
                                                rowArray = rowsArray[2] as! [Any]
                                                stormCenterDetail.pressureText = rowArray[0] as? String
                                                stormCenterDetail.pressureValue = rowArray[1] as? String
                                            }
                                        } else {
                                            let mapNode = (nodesDictionary![kSubNodeKey] as? [String: Any])
                                            if mapNode != nil {
                                                let mapData = mapNode?["map"] as Any?
                                                if mapData != nil {
                                                    do {
                                                        stormCenterDetail.mapData = try NSKeyedArchiver.archivedData(withRootObject: mapData!,requiringSecureCoding: false) as NSData
                                                    } catch {
                                                        print(error)
                                                    }
                                                }
                                            }
                                        }
                                        // HAPP-591
                                        let loopImagesArray = (nodesDictionary!["loop_images"] as? [Any])
                                        if loopImagesArray != nil {
                                            for (index, imageArray) in loopImagesArray!.enumerated() {
                                                let stormCenterImages = NSEntityDescription.insertNewObject(forEntityName: kEntityStormCenterImages, into: self.managedObjectContext!) as! StormCenterImages
                                                stormCenterImages.imageURL = (imageArray as? [Any])?.last as? String

                                                if stormCenterImages.imageURL != nil {
                                                    let imageIndex = loopImagesArray!.count - index

                                                    let imagePath = String(format: "%@_loop_%d_%@", arguments: [stormCenter.idx!, Int(imageIndex), (URL(string: stormCenterImages.imageURL!)?.lastPathComponent)!])
                                                    let imageNameWithPath = self.getPathForImage(imagePath)
                                                    stormCenterImages.imageNameWithPath = imageNameWithPath
                                                    stormCenterImages.stormCenterDetail = stormCenterDetail
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            stormCenterDetail.stormCenter = stormCenter
                        }
                    }
                }
                success = true
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kHurricaneDataDownloaded), object: nil)
        return success
    }

    func getStormDataforID(_ stormId: String) -> [Any]? {
        if self.managedObjectContext == nil {
            return nil
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: kEntityStormCenter, in: self.managedObjectContext!)!
        fetchRequest.entity = entity
        let predicate = NSPredicate(format: "idx ==[c] %@", stormId)
        fetchRequest.predicate = predicate
        var error: Error?
        var resultingData: [AnyObject]?
        do {
            resultingData = try self.managedObjectContext!.fetch(fetchRequest)
        } catch let error1 {
            error = error1
            print("Error in fetching entities \(String(describing: error))")
        }
        if resultingData == nil {
            print("Couldn't get object for entity : \(kEntityStormCenter)")
        }
        return resultingData
    }

    func saveTropicWatchdata(_ tropicsDictionary: [AnyHashable: Any]) -> Bool {
        print("Saving Tropics Watch data")
        var success = false
        success = self.deleteData(forEntity: kEntityTropicWatch)
        success = self.deleteData(forEntity: kEntityTropicWatchDetail)
        let tropicWatch = NSEntityDescription.insertNewObject(forEntityName: kEntityTropicWatch, into: self.managedObjectContext!) as! TropicWatch
        tropicWatch.name = (tropicsDictionary["name"] as? String)
        tropicWatch.subhead = (tropicsDictionary["subhead"] as? String)
        tropicWatch.idx = (tropicsDictionary["id"] as? String)
        let tropicWatchArray = (tropicsDictionary[kTabsKey] as? [Any])
        if tropicWatchArray != nil {
            for (index, tabParentDictionary) in tropicWatchArray!.enumerated() {
                let tabDictionary = tabParentDictionary as? [String: Any]
                if tabDictionary != nil {
                    let nodesArray = (tabDictionary![kNodesKey] as? [Any])
                    let tropicWatchDetail = NSEntityDescription.insertNewObject(forEntityName: kEntityTropicWatchDetail, into: self.managedObjectContext!) as! TropicWatchDetail
                    tropicWatchDetail.index = index as NSNumber?
                    tropicWatchDetail.name = (tabDictionary![kNameKey] as? String)
                    if nodesArray != nil {
                        for nodesParentDictionary: Any in nodesArray! {
                            let nodesDictionary = nodesParentDictionary as? [String: Any]
                            if nodesDictionary != nil {
                                let node = (nodesDictionary![kSubNodeKey] as? String)
                                if node == "image" {
                                    let imageURL = (nodesDictionary!["src"] as? String)
                                    if imageURL != nil {
                                        let imagePath = String(format: "%@_%d_%@", arguments: [tropicWatch.idx!, index, (URL(string: imageURL!)?.lastPathComponent)!])
                                        let imageNameWithPath = self.getPathForImage(imagePath)
                                        tropicWatchDetail.imageURL = imageURL
                                        tropicWatchDetail.imageNameWithPath = "\(imageNameWithPath)"
                                    }
                                    
                                    let loopGifURL = (nodesDictionary!["loop_gif"] as? String)
                                    
                                    if loopGifURL != nil {
                                        tropicWatchDetail.loop_gif = "\(loopGifURL!)"
//                                        self.downloadGIF(from: loopGifURL!, completion: { (downloadedURL) in
//                                            tropicWatchDetail.loop_gif = downloadedURL?.absoluteString
//                                        })
                                    }
                                    
                                    
                                } else if node == "text" {
                                    tropicWatchDetail.discussion = (nodesDictionary!["text"] as? String)
                                } else {
                                    let mapNode = (nodesDictionary![kSubNodeKey] as? [String: Any])
                                    if mapNode != nil {
                                        let mapData = mapNode?["map"] as Any?
                                        if mapData != nil {
                                            do {
                                                tropicWatchDetail.mapData = try NSKeyedArchiver.archivedData(withRootObject: mapData!,requiringSecureCoding: false) as NSData
                                            } catch {
                                                print(error)
                                            }
                                        }
                                    }
                                }
                                let loopImagesArray = (nodesDictionary!["loop_images"] as? [Any])
                                if loopImagesArray != nil {
                                    for (index, imageArray) in loopImagesArray!.enumerated() {
                                        let tropicWatchImages = NSEntityDescription.insertNewObject(forEntityName: kEntityTropicWatchImages, into: self.managedObjectContext!) as! TropicWatchImages
                                        tropicWatchImages.imageURL = (imageArray as? [Any])?.last as? String

                                        if tropicWatchImages.imageURL != nil {
                                            let imageIndex = loopImagesArray!.count - index
                                            tropicWatchImages.index = imageIndex as NSNumber?
                                            let imagePath = String(format: "%@_loop_%d_%@", arguments: [tropicWatch.idx!, Int(imageIndex), (URL(string: tropicWatchImages.imageURL!)?.lastPathComponent)!])
                                            let imageNameWithPath = self.getPathForImage(imagePath)
                                            tropicWatchImages.imageNameWithPath = imageNameWithPath
                                            tropicWatchImages.tropicWatchDetail = tropicWatchDetail
                                        }
                                    }
                                }
                            }
                        }
                    }
                    tropicWatchDetail.tropicWatch = tropicWatch
                    success = true
                }
            }
        }
        return success
    }

    func getTropicWatchData() -> [Any]? {
        if self.managedObjectContext == nil {
            self.managedObjectContext = DataManager.sharedInstance.mainObjectContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: kEntityTropicWatchDetail, in: self.managedObjectContext!)!
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var error: Error?
        var resultingData: [AnyObject]?
        do {
            resultingData = try self.managedObjectContext!.fetch(fetchRequest)
        } catch let error1 {
            error = error1
            print("Error in fetching entities \(String(describing: error))")
        }
        if resultingData == nil {
            print("Couldn't get object for entity \(kEntityTropicWatchDetail)")
        }
        return resultingData
    }

    func saveWatchAndWarningsData(_ watchAndWarningDictionary: [AnyHashable: Any]) -> Bool {
        print("Saving Watches n Warnings data")
        var success = false
        success = self.deleteData(forEntity: kEntityWatchesAndWarnings)
        success = self.deleteData(forEntity: kEntityWatchesAndWarningsDetail)
        let watchesAndWarnings = NSEntityDescription.insertNewObject(forEntityName: kEntityWatchesAndWarnings, into: self.managedObjectContext!) as! WatchesAndWarnings
        watchesAndWarnings.name = (watchAndWarningDictionary["name"] as? String)
        watchesAndWarnings.subhead = (watchAndWarningDictionary["subhead"] as? String)
        watchesAndWarnings.idx = (watchAndWarningDictionary["id"] as? String)
        let watchesAndWarningsArray = (watchAndWarningDictionary[kTabsKey] as? [Any])
        if watchesAndWarningsArray != nil {
            for (index, tabParentDictionary) in watchesAndWarningsArray!.enumerated() {
                let tabDictionary = tabParentDictionary as? [String: Any]
                if tabDictionary != nil {
                    let nodesArray = (tabDictionary![kNodesKey] as? [Any])
                    let watchesAndWarningsDetail = NSEntityDescription.insertNewObject(forEntityName: kEntityWatchesAndWarningsDetail, into: self.managedObjectContext!) as! WatchesAndWarningsDetail
                    watchesAndWarningsDetail.index = index as NSNumber?
                    watchesAndWarningsDetail.name = (tabDictionary![kNameKey] as? String)
                    if nodesArray != nil {
                        for nodesParentDictionary: Any in nodesArray! {
                            let nodesDictionary = nodesParentDictionary as? [AnyHashable: Any]
                            if nodesDictionary != nil {
                                let node = (nodesDictionary![kSubNodeKey] as? String)
                                if node == "image" {
                                    let imageURL = (nodesDictionary!["src"] as? String)
                                    if imageURL != nil {
                                        let imageName = String(format: "%@_%d_%@", arguments: [watchesAndWarnings.idx!, index, (imageURL! as NSString).lastPathComponent])
                                        let imageNameWithPath = self.getPathForImage(imageName)
                                        watchesAndWarningsDetail.imageURL = imageURL
                                        watchesAndWarningsDetail.imageNameWithPath = imageNameWithPath
                                    }
                                } else if node == "text" {
                                    watchesAndWarningsDetail.discussion = (nodesDictionary!["text"] as! String)
                                } else {
                                    let mapNode = (nodesDictionary![kSubNodeKey] as? [String: Any])
                                    if mapNode != nil {
                                        let mapData = mapNode?["map"] as Any?
                                        if mapData != nil {
                                            do {
                                                watchesAndWarningsDetail.mapData = try NSKeyedArchiver.archivedData(withRootObject: mapData!,requiringSecureCoding: false) as NSData
                                            } catch {
                                                print(error)
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    watchesAndWarningsDetail.watchesAndWarnings = watchesAndWarnings
                    success = true
                }
            }
        }
        return success
    }

    func getWatchesAndWarningsData() -> [Any]? {
        if self.managedObjectContext == nil {
            return nil
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: kEntityWatchesAndWarningsDetail, in: self.managedObjectContext!)!
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var error: Error?
        var resultingData: [AnyObject]?
        do {
            resultingData = try self.managedObjectContext!.fetch(fetchRequest)
        } catch let error1 {
            error = error1
            print("Error in fetching entities \(String(describing: error))")
        }
        if resultingData == nil {
            print("Couldn't get object for entity \(kEntityWatchesAndWarningsDetail)")
        }
        return resultingData
    }

    func deleteData(forEntity kEntity: String) -> Bool {
        if self.managedObjectContext == nil {
            return false
        }
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let entity = NSEntityDescription.entity(forEntityName: kEntity, in: self.managedObjectContext!)!
            fetchRequest.entity = entity
            let fetchResultArray = try self.managedObjectContext!.fetch(fetchRequest) as! [NSManagedObject]
            for managedObject: NSManagedObject in fetchResultArray {
                self.managedObjectContext!.delete(managedObject)
            }
        } catch let error {
            print("Unresolved error \(String(describing: error))")
        }
        return true
    }

    func saveAllDataNow() {
        var error: Error?
        do {
            try self.managedObjectContext!.save()
        } catch let error1 {
            error = error1
            print("Error in saving data \(String(describing: error))")
        }
    }

    func getEntityForId(_ idx: String) -> String? {
        if self.managedObjectContext == nil {
            return nil
        }
        if self.executeFetch(forEntity: kEntityNotifications, forId: idx) {
            return kEntityNotifications
        } else if self.executeFetch(forEntity: kEntityStormCenter, forId: idx) {
            return kEntityStormCenter
        } else if self.executeFetch(forEntity: kEntityTropicWatch, forId: idx) {
            return kEntityTropicWatch
        } else if self.executeFetch(forEntity: kEntityWatchesAndWarnings, forId: idx) {
            return kEntityWatchesAndWarnings
        }

        return nil
    }

    func executeFetch(forEntity kEntity: String, forId idx: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: kEntity, in: self.managedObjectContext!)!
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "idx ==[c] %@", idx)
        fetchRequest.predicate = predicate
        var error: Error?
        var resultingData: [AnyObject]?
        do {
            resultingData = try self.managedObjectContext!.fetch(fetchRequest)
        } catch let error1 {
            error = error1
            print("Error in fetching entities \(String(describing: error))")
        }
        if resultingData != nil && resultingData!.count > 0 {
            print("Couldn't get object for entity \(kEntity)")
            return true
        }
        return false
    }

    func getDataForEntity(_ entity: String, id idx: String) -> [Any]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDesc = NSEntityDescription.entity(forEntityName: entity, in: self.managedObjectContext!)!
        fetchRequest.entity = entityDesc
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "idx ==[c] %@", idx)
        fetchRequest.predicate = predicate
        var error: Error?
        var resultingData: [AnyObject]?
        do {
            resultingData = try self.managedObjectContext!.fetch(fetchRequest)
        } catch let error1 {
            error = error1
            print("Error in fetching entities \(String(describing: error))")
        }
        if resultingData == nil {
            print("Couldn't get object for entity \(entity)")
        }
        return resultingData
    }

    func getPathForImage(_ imageName: String) -> String {
        let storePath = URL(fileURLWithPath: self.sharedCacheImagesPath()).appendingPathComponent(imageName as String)
        return storePath.absoluteString
    }

    func sharedCacheImagesPath() -> String {
        if DataDownloadManager.SharedImagesPath != nil {
            return DataDownloadManager.SharedImagesPath!
        }

        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as NSArray
        let libraryPath = paths[0] as! NSString
        let sharedImagesPath = libraryPath.appendingPathComponent("Images")
        let fileManager = FileManager.default

        DataDownloadManager.SharedImagesPath = sharedImagesPath

        // Create directory on disk
        if !fileManager.fileExists(atPath: sharedImagesPath) {
            do {
                try fileManager.createDirectory(atPath: sharedImagesPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Error creating directory path: \(error.localizedDescription)")
            }
        }
        return DataDownloadManager.SharedImagesPath!
    }
    
    func downloadGIF(from urlString: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }

        // Create a URLSession to handle the download
        let session = URLSession.shared

        // Start the download task
        let downloadTask = session.downloadTask(with: url) { (tempURL, response, error) in
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let tempURL = tempURL else {
                print("No file URL received")
                completion(nil)
                return
            }

            // Get the file's data and move it to the desired location
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)

            do {
                // Remove any existing file at the destination path
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                
                // Move the downloaded file from temporary location to the final destination
                try fileManager.moveItem(at: tempURL, to: destinationURL)
                print("GIF downloaded to: \(destinationURL.path)")
                completion(destinationURL)
            } catch {
                print("Error saving file: \(error.localizedDescription)")
                completion(nil)
            }
        }

        downloadTask.resume()
    }

}
