//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 16/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var photos: NSSet?

}
