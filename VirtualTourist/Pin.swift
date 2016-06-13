//
//  Pin.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

    convenience init(latitude: Double, longitude: Double, context : NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
