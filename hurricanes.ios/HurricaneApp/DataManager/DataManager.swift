//
//  DataManager.swift
//  Hurricane
//
//  Created by Swati Verma on 12/09/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import Foundation
import CoreData

private let _singletonInstance = DataManager()
let DataManagerDidSaveNotification = "DataManagerDidSaveNotification"
let DataManagerDidSaveFailedNotification = "DataManagerDidSaveFailedNotification"

class DataManager: NSObject {

    static var SharedDocumentsPath: String?

    class var sharedInstance: DataManager {
        return _singletonInstance
    }

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.grahamdigital.test" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Application", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Application.sqlite")
        var error: NSError?
        var failureReason = "There was an error creating or loading the application's saved data."
        var option = [NSMigratePersistentStoresAutomaticallyOption: true,
                      NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: option)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }

        return coordinator
    }()

    lazy var mainObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError?
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: DataManagerDidSaveFailedNotification), object: nil)
                }
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: DataManagerDidSaveNotification), object: nil)
            }
        }
    }

    func searchForEntity(_ entityName: String, withPredicate predicate: NSPredicate?, andSortKey sortKey: String?, andSortAscending sortAscending: Bool) -> [AnyObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.mainObjectContext!)!
        request.entity = entity
        request.predicate = predicate
        if sortKey != nil {
            let sortdescriptor = NSSortDescriptor(key: sortKey, ascending: sortAscending)
            request.sortDescriptors = [sortdescriptor]
        }
        var error: NSError?
        print("fetching")
        var mutableFetchResults: [AnyObject]?
        do {
            mutableFetchResults = try self.mainObjectContext!.fetch(request)
        } catch let error1 as NSError {
            error = error1
            print("Error in fetching entities \(String(describing: error))")
        }
        if mutableFetchResults == nil {
            print("Couldn't get object for entity \(entityName)")
        }
        return mutableFetchResults
    }

    func getObjectsForEntity(_ entityName: String, withSortKey sortKey: String, andSortAscending sortAscending: Bool) -> [AnyObject]? {
        return self.searchForEntity(entityName, withPredicate: nil, andSortKey: sortKey, andSortAscending: sortAscending)
    }

    func countForEntity(_ entityName: String, withPredicate predicate: NSPredicate?) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.mainObjectContext!)
        request.entity = entity
        request.includesSubentities = false
        if predicate != nil {
            request.predicate = predicate
        }
        var count = 0
        var error: NSError?
        do {
            count =  try self.mainObjectContext!.count(for: request)
        } catch let error1 as NSError {
            error = error1
            print("Error in fetching entities \(String(describing: error))")
        }
        if count == NSNotFound {
            print("Couldn't get count for entity \(String(describing: entity))")
        }
        return count
    }

    func countForEntity(_ entityName: String) -> Int {
        return self.countForEntity(entityName, withPredicate: nil)
    }

    func deleteAllObjectsForEntity(_ entityName: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.mainObjectContext!)!
        request.entity = entity
        request.includesPropertyValues = false
        var error: NSError?
        var fetchResults: [AnyObject]?
        do {
            fetchResults = try self.mainObjectContext!.fetch(request)
        } catch let error1 as NSError {
            error = error1
            print("Error in fetching entities \(String(describing: error))")
        }
        if fetchResults != nil {
            for manObj: AnyObject in fetchResults! {
                self.mainObjectContext!.delete(manObj as! NSManagedObject)
            }
        } else {
            print("Couldn't delete objects for entity \(entityName)")
        }
        return true
    }

    func sharedDocumentsPath() -> String? {
        if DataManager.SharedDocumentsPath != nil {
            return DataManager.SharedDocumentsPath
        }
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        DataManager.SharedDocumentsPath = URL(fileURLWithPath: libraryPath).appendingPathComponent("Database").absoluteString
        let manager = FileManager.default
        var isDirectory: ObjCBool = ObjCBool(false)
        if !manager.fileExists(atPath: DataManager.SharedDocumentsPath!, isDirectory: &isDirectory) {
            let attr = [ FileAttributeKey.protectionKey: FileProtectionType.complete ]
            do {
                try manager.createDirectory(atPath: DataManager.SharedDocumentsPath!, withIntermediateDirectories: true, attributes: attr)
            } catch let error as NSError {
                print("Error creating directory path: \(error.localizedDescription)")
            }
        }
        return DataManager.SharedDocumentsPath
    }
}
