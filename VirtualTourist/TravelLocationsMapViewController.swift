//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: CoreDataViewController, MKMapViewDelegate {

    // MARK: Properties
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteLabel: UILabel!

    var editMode: Bool = false
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStack()
        setUpMapView()
        loadPins()
    }
    
    // MARK: Protocols
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if editMode {
            let annotation = view.annotation!
            mapView.removeAnnotation(annotation)
            let pin = getPinAssociatedWithAnnotation(annotation)
            stack.context.deleteObject(pin)
        } else {
            let controller = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
            controller.annotation = view.annotation
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: Actions
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        setEditMode()
    }
}

