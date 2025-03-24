//
//  Notification+CoreDataProperties.swift
//  Hurricane
//
//  Created by Sachin Ahuja on 12/05/17.
//  Copyright © 2017 PNSDigital. All rights reserved.
//

import Foundation
import CoreData

extension Notification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notification> {
        return NSFetchRequest<Notification>(entityName: "Notification")
    }

    @NSManaged public var active: NSNumber?
    @NSManaged public var banner: String?
    @NSManaged public var callleters: String?
    @NSManaged public var endTime: String?
    @NSManaged public var idx: String?
    @NSManaged public var imageNameWithPath: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var index: NSNumber?
    @NSManaged public var startTime: String?
    @NSManaged public var text: String?
    @NSManaged public var timesince: String?
    @NSManaged public var title: String?
    @NSManaged public var met: String?

}
