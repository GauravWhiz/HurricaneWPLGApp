//
//  NotificationSingleton.swift
//  Hurricane
//
//  Created by Swati Verma on 04/07/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation

@objc
class NotificationSingleton: NSObject {
    var notificationsArray = [Notification]()
    var isNotificationBecomeActive: Bool = false
    var timer: Timer?
    var isNotificationTimeBaseRequired: Bool = false

    static let sharedInstance = NotificationSingleton()

    func startNotificationsTimer() {
        if self.notificationsArray.count == 0 {
            return
        }
        if isNotificationTimeBaseRequired {
            self.startNotificationBasedOnTimeBased()
        } else {
            self.startNotificationBasedOnCountBased()
        }
    }

    func startNotificationBasedOnCountBased() {
        for notification: Notification in self.notificationsArray {
            let dictionary: [AnyHashable: Any] = [
                "Notification": notification
            ]

            let startTimer: Timer = Timer(fireAt: Date(), interval: 0.0, target: self, selector: #selector(NotificationSingleton.startNotifications(_:)), userInfo: dictionary, repeats: false)
            RunLoop.current.add(startTimer, forMode: RunLoop.Mode.default)
        }
    }

    func startNotificationBasedOnTimeBased() {
        for notification: Notification in self.notificationsArray {
            let dateFormatter: DateFormatter = DateFormatter()
            // Thu, 23 May 2013 07:51:47 GMT
            dateFormatter.dateFormat = kDefaultDateFormat
            let startDateString = notification.startTime
            let endDateString = notification.endTime
            var startDate: Date?
            var endDate: Date?
            if startDateString != nil {
                startDate = dateFormatter.date(from: startDateString!)
            }
            if endDateString != nil {
                endDate = dateFormatter.date(from: endDateString!)
            }

            var startTimer: Timer
            var stopTimer: Timer
            let currentDate: Date = Date()
            if startDate != nil && endDate != nil {
                /* START SHOWING NOTIFICATION */
                if (endDate!.compare(currentDate) == ComparisonResult.orderedDescending) && (startDate!.compare(currentDate) == ComparisonResult.orderedDescending) {
                    NSLog("startdate + endDate is later than currentDate")
                    let dictionary: [AnyHashable: Any] = [
                        "Notification": notification
                    ]

                    startTimer = Timer(fireAt: startDate!, interval: 0.0, target: self, selector: #selector(NotificationSingleton.startNotifications(_:)), userInfo: dictionary, repeats: false)
                    RunLoop.current.add(startTimer, forMode: RunLoop.Mode.default)
                } else if (currentDate.compare(startDate!) == ComparisonResult.orderedDescending) && (endDate!.compare(currentDate) == ComparisonResult.orderedDescending) {
                    NSLog("currentDate is between startDate and endDate")
                    let dictionary: [AnyHashable: Any] = [
                        "Notification": notification
                    ]

                    startTimer = Timer(fireAt: Date(), interval: 0.0, target: self, selector: #selector(NotificationSingleton.startNotifications(_:)), userInfo: dictionary, repeats: false)
                    RunLoop.current.add(startTimer, forMode: RunLoop.Mode.default)
                } else if currentDate.compare(endDate!) == ComparisonResult.orderedDescending {
                    NSLog("currentDate is later than endDate")
                }

                /* STOP SHOWING NOTIFICATION */
                if endDate!.compare(currentDate) == ComparisonResult.orderedDescending {
                    NSLog("endDate is later than CurrentDate")
                    let dictionary: [AnyHashable: Any] = [
                        "Notification": notification
                    ]

                    stopTimer = Timer(fireAt: endDate!, interval: 0.0, target: self, selector: #selector(NotificationSingleton.stopNotifications(_:)), userInfo: dictionary, repeats: false)
                    RunLoop.current.add(stopTimer, forMode: RunLoop.Mode.default)
                }
            }
        }
    }

    @objc func startNotifications(_ startTimer: Timer) {
        print("startNotifications Fired, %@", Date())
        self.isNotificationBecomeActive = true
    }

    @objc func stopNotifications(_ stopTimer: Timer) {
        print("stopNotifications Fired, %@", Date())
        self.isNotificationBecomeActive = true
    }
}
