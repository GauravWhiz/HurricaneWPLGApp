//
//  NotificationController.swift
//  Hurricane
//
//  Created by Virendra Sehrawat on 19/07/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import WatchKit
import Foundation

class NotificationController: WKUserNotificationInterfaceController {

    var apsKeyString: NSString = "aps"
    var alertKeyString: NSString = "alert"
    var textKeyString: NSString = "body"

    @IBOutlet var notificationText: WKInterfaceLabel!
    @IBOutlet var notificationTitle: WKInterfaceLabel!

    override init() {
        // Initialize variables here.
        super.init()

        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    /*
     override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
     // This method is called when a local notification needs to be presented.
     // Implement it if you use a dynamic notification interface.
     // Populate your dynamic notification interface as quickly as possible.
     //
     // After populating your dynamic notification interface call the completion block.
     completionHandler(.Custom)
     }
     */

     func didReceiveRemoteNotification(_ remoteNotification: [AnyHashable: Any], withCompletion completionHandler: (@escaping (WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a remote notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.

        let apsDict: NSDictionary? = remoteNotification[apsKeyString] as? NSDictionary
        let alertTitle = "Hurricane Alert"
        self.notificationText.setText(apsDict?.object(forKey: alertKeyString) as? String)
        self.notificationTitle.setText(alertTitle)
        completionHandler(.custom)
    }

}
