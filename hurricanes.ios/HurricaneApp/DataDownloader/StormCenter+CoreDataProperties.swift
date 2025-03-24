//
//  StormCenter+CoreDataProperties.swift
//  Hurricane
//
//  Created by Swati Verma on 13/07/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension StormCenter {

    @NSManaged var category: NSNumber?
    @NSManaged var fullName: String?
    @NSManaged var idx: String?
    @NSManaged var index: NSNumber?
    @NSManaged var stormName: String?
    @NSManaged var stormNum: NSNumber?
    @NSManaged var subhead: String?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var discussionHtml: String?
   // @NSManaged var updated: String?
    @NSManaged var stormCenterDetail: NSSet?
    @NSManaged var stormSurge: String?
    @NSManaged var stormPriority: NSNumber?

}
