//
//  CoreDataViewController.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import UIKit
import CoreData

class CoreDataViewController: UIViewController {

    var stack: CoreDataStack!

    func setStack() {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        stack = delegate.stack
    }
    
    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            executeSearch()
        }
    }
    
    // Do not worry about this initializer. It has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func performFetchRequest(entityName: String, sortDescriptors: [NSSortDescriptor]?, predicate: NSPredicate? = nil) {
        let fr = NSFetchRequest(entityName: entityName)
        fr.sortDescriptors = sortDescriptors
        fr.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}
