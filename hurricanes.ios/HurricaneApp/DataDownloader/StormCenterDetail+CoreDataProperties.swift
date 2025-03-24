//
//  StormCenterDetail+CoreDataProperties.swift
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

extension StormCenterDetail {

    @NSManaged var discussion: String?
    @NSManaged var imageNameWithPath: String?
    @NSManaged var imageURL: String?
    @NSManaged var index: NSNumber?
    @NSManaged var name: String?
    @NSManaged var pressureText: String?
    @NSManaged var pressureValue: String?
    @NSManaged var status: String?
    @NSManaged var windSpeedText: String?
    @NSManaged var windSpeedValue: String?
    @NSManaged var stormCenter: StormCenter?
    @NSManaged var stormCenterImages: NSSet?
    @NSManaged var mapData: NSData?
    @NSManaged var loop_gif: String?
}
