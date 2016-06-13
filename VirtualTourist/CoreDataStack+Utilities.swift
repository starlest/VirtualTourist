//
//  CoreDataStack+Utilities.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import CoreData

// MARK:  - TypeAliases
typealias BatchTask = (workerContext: NSManagedObjectContext) -> ()

// MARK:  - Notifications
enum CoreDataStackNotifications : String {
    case ImportingTaskDidFinish = "ImportingTaskDidFinish"
}

extension CoreDataStack {
    
    func addStoreTo(coordinator coord : NSPersistentStoreCoordinator, storeType: String, configuration: String?, storeURL: NSURL, options : [NSObject : AnyObject]?) throws {
        try coord.addPersistentStoreWithType(storeType, configuration: configuration, URL: storeURL, options: options)
    }
    
    func dropAllData() throws {
        try coordinator.destroyPersistentStoreAtURL(dbURL, withType:NSSQLiteStoreType, options: nil)
        try addStoreTo(coordinator: self.coordinator, storeType: NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
    
    // MARK: Background Operations
    
    func performBackgroundBatchOperation(batch: BatchTask) {
        
        backgroundContext.performBlock {
            batch(workerContext: self.backgroundContext)
            
            // Save it to the parent context, so normal saving
            // can work
            do {
                try self.backgroundContext.save()
            } catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
    
    func performBackgroundImportingBatchOperation(batch: BatchTask) {
        
        // Create temp coordinator
        let tmpCoord = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        
        do {
            try addStoreTo(coordinator: tmpCoord, storeType: NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
        } catch {
            fatalError("Error adding a SQLite Store: \(error)")
        }
        
        // Create temp context
        let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        moc.name = "Importer"
        moc.persistentStoreCoordinator = tmpCoord
        
        // Run the batch task, save the contents of the moc & notify
        moc.performBlock(){
            batch(workerContext: moc)
            
            do {
                try moc.save()
            }catch{
                fatalError("Error saving importer moc: \(moc)")
            }
            
            let nc = NSNotificationCenter.defaultCenter()
            let n = NSNotification(name: CoreDataStackNotifications.ImportingTaskDidFinish.rawValue,
                object: nil)
            nc.postNotification(n)
        }
    }
    
    // MARK: Save Methods
    
    func save() {
        // We call this synchronously, but it's a very fast
        // operation (it doesn't hit the disk). We need to know
        // when it ends so we can call the next save (on the persisting
        // context). This last one might take some time and is done
        // in a background queue
        context.performBlockAndWait() {
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // now we save in the background
                self.persistingContext.performBlock(){
                    do {
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(delayInSeconds : Int){
        
        if delayInSeconds > 0 {
            save()
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInNanoSeconds))
            
            dispatch_after(time, dispatch_get_main_queue(), {
                self.autoSave(delayInSeconds)
            })
        }
    }
}