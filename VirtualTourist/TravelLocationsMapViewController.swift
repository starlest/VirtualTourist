//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Properties
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
    }
    
    // MARK: Actions
    @IBAction func editButtonPressed(sender: AnyObject) {
    }
    
    // MARK: Helpers
    func setUpMapView() {
        mapView.delegate = self
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsMapViewController.addAnnotation(_:)))
        uilgr.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(uilgr)
    }
    
    func addAnnotation(gestureRecognizer: UIGestureRecognizer){
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
    }
}

