//
//  WatchesAndWarnings+CoreDataProperties.swift
//  Hurricane
//
//  Created by Swati Verma on 14/07/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WatchesAndWarnings {

    @NSManaged var idx: String?
    @NSManaged var index: NSNumber?
    @NSManaged var name: String?
    @NSManaged var subhead: String?
    @NSManaged var watchesAndWarningsDetail: NSSet?

}
