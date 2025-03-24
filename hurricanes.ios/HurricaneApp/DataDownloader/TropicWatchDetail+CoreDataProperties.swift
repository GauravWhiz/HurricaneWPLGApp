//
//  TropicWatchDetail+CoreDataProperties.swift
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

extension TropicWatchDetail {

    @NSManaged var discussion: String?
    @NSManaged var imageNameWithPath: String?
    @NSManaged var imageURL: String?
    @NSManaged var index: NSNumber?
    @NSManaged var name: String?
    @NSManaged var tropicWatch: TropicWatch?
    @NSManaged var tropicWatchImages: NSSet?
    @NSManaged var mapData: NSData?
    @NSManaged var loop_gif: String?
}
