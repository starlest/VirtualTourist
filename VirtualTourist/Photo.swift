//
//  Photo.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {
    
    convenience init(photoData: NSData, pin: Pin, context : NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName(Globals.Entities.Photo, inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.imageData = photoData
            self.pin = pin
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
