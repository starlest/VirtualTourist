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

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStack()
        setUpMapView()
        loadPins()
    }
    
    // MARK: Protocols
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        controller.annotation = view.annotation
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Actions
    
    @IBAction func editButtonPressed(sender: AnyObject) {
    }
}

