//
//  InterfaceController.swift
//  Hurricane
//
//  Created by Virendra Sehrawat on 20/07/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import WatchKit
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

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var hurricaneTable: WKInterfaceTable!
    var stormArray: NSArray?
    var notificationStormId: NSString?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.downloadData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if rowIndex < self.stormArray?.count {
            self.pushController(withName: "StormDetailViewController", context: self.stormArray?.object(at: rowIndex))
        }
    }

    func downloadData() {

        var kApiURL = ""
        var kApplicationGroup = ""

        #if KPRCWatch
            kApiURL = "https://s3.amazonaws.com/gmg-hurricanes/hurricanes/KPRC.json"
            kApplicationGroup = "group.grahamdigital.hurricane.kprc"

            /***************************************  KSAT   ********************************************/
        #elseif KSATWatch
            kApiURL = "https://s3.amazonaws.com/gmg-hurricanes/hurricanes/KSAT.json"
            kApplicationGroup = "group.grahamdigital.hurricane.ksat"

            /***************************************  WJXT   ********************************************/
        #elseif WJXTWatch
            kApiURL = "https://s3.amazonaws.com/gmg-hurricanes/hurricanes/WJXT.json"
            kApplicationGroup = "group.grahamdigital.hurricane.wjxt"

            /***************************************  WKMG   ********************************************/
        #elseif WKMGWatch
            kApiURL = "https://s3.amazonaws.com/gmg-hurricanes/hurricanes/WKMG.json"
            kApplicationGroup = "group.grahamdigital.hurricane.wkmg"

            /***************************************  WPLG   ********************************************/
        #elseif WPLGWatch
            kApiURL = "https://s3.amazonaws.com/gmg-hurricanes/hurricanes/WPLG.json"
            kApplicationGroup = "group.grahamdigital.hurricane.wplg"

            /***************************************  Test   ********************************************/
        #elseif TESTWatch
            kApiURL = "https://s3.amazonaws.com/gmg-hurricanes-dev/hurricanes/TEST1.json"
            kApplicationGroup = "group.GrahamDigital.TestHurricane"

            /***************************************  END   ********************************************/
        #endif

        let defaults = UserDefaults(suiteName: kApplicationGroup)
        let dataUrl = defaults!.object(forKey: "API_URL") as? String
        var url: URL?
        if dataUrl != nil && dataUrl?.count > 0 {
            url = URL(string: dataUrl!)
        } else {
            url = URL(string: kApiURL)
        }

        let request = URLRequest(url: url!)
        let session = URLSession.shared

        let task = session.dataTask(with: request, completionHandler: { data, response, error in

            if let error = error {
                print(error.localizedDescription)

            } else if let httpresponse = response as? HTTPURLResponse {
                if httpresponse.statusCode == 200 {
                    DispatchQueue.main.async(execute: {
                        self.parseData(data!)
                    })

                }
            }
        })
        task.resume()
    }

    func parseData(_ data: Data) {

        var dataDictionary: NSDictionary?

        do {
            dataDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
        } catch let error as NSError {
            print("Error in making jsonObject : \(error)")
        }

        if let stormArray = dataDictionary?.object(forKey: "storms") as? NSArray {
            self.stormArray = stormArray
        }

        if self.notificationStormId != nil {
            var isNotificationAvailable = false

            for storm: NSDictionary in stormArray as! [NSDictionary] {
                if (storm.object(forKey: "id") as? String)! == self.notificationStormId! as String {
                    isNotificationAvailable = true
                    self.pushController(withName: "StormDetailViewController", context: storm)
                    self.notificationStormId = nil
                }
            }
            if !isNotificationAvailable {
                self.configureTableWithData(stormArray!)
            }
        } else {

            self.configureTableWithData(stormArray!)
        }

    }

    func configureTableWithData(_ dataArray: NSArray) {
        if dataArray.count == 0 {
            self.hurricaneTable.setNumberOfRows(1, withRowType: "HurricaneController")
            let hurricaneRow: HurricaneRowType = (self.hurricaneTable.rowController(at: 0) as? HurricaneRowType)!
            hurricaneRow.hurricaneCategoryGroup.setBackgroundColor(UIColor.clear)
            hurricaneRow.hurricaneCategoryGroup.setWidth(120)
            hurricaneRow.hurricaneCategoryGroup.setHeight(120)
            hurricaneRow.hurricaneCategory.setWidth(120)
            hurricaneRow.hurricaneCategory.setHeight(120)
            hurricaneRow.hurricaneCategory.setText("No Active Storms")
            hurricaneRow.hurricaneName.setText("")
        } else {
            self.hurricaneTable.setNumberOfRows(dataArray.count, withRowType: "HurricaneController")

            for i in 0...(self.hurricaneTable.numberOfRows - 1) {
                let hurricaneRow: HurricaneRowType = (self.hurricaneTable.rowController(at: i) as? HurricaneRowType)!
                let dataDict = dataArray.object(at: i) as? NSDictionary
                hurricaneRow.hurricaneName.setText(dataDict?.object(forKey: "name") as? String)
                let category = dataDict?.object(forKey: "category") as? NSInteger
                if (category != nil) && (category != 0) {
                    hurricaneRow.hurricaneCategory.setText("\(Int(category!))")
                } else {
                     hurricaneRow.hurricaneCategory.setText("t")
                }
            }
        }
    }

    func handleAction(withIdentifier identifier: String?, forRemoteNotification remoteNotification: [AnyHashable: Any]) {
        if identifier == "readAction" {
            self.notificationStormId = remoteNotification["openScreen" as NSObject] as? String as NSString?
        }
    }
}
