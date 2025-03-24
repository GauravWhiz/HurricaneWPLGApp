//
//  TropicWatch+CoreDataProperties.swift
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

extension TropicWatch {

    @NSManaged var idx: String?
    @NSManaged var index: NSNumber?
    @NSManaged var name: String?
    @NSManaged var subhead: String?
    @NSManaged var tropicWatchDetail: NSSet?

}
