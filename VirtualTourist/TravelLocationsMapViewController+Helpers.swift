//
//  TravelLocationsMapViewController+Helpers.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import MapKit
import CoreData

extension TravelLocationsMapViewController {
    
    func setUpMapView() {
        mapView.delegate = self
        setUpMapViewGestureRecognizer()
        setMapViewRegion()
        
        // Reference mapView in appDelegate so that its state
        // could be saved when the app closes or goes into the background
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mapView = mapView
    }
    
    func loadPins() {
        // Get the Stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create the fetch request
        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [
            NSSortDescriptor(key: "latitude", ascending: true),
            NSSortDescriptor(key: "longitude", ascending: true)
        ]
        
        // Create a fetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        let pins = fetchedResultsController?.fetchedObjects as! [Pin]
        
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude as! Double, longitude: pin.longitude as! Double)
            mapView.addAnnotation(annotation)
        }
    }
    
    private func setUpMapViewGestureRecognizer() {
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsMapViewController.addAnnotation(_:)))
        uilgr.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uilgr)
    }
    
    func addAnnotation(gestureRecognizer: UIGestureRecognizer){
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let pin = Pin(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude, context: fetchedResultsController!.managedObjectContext)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude as! Double, longitude: pin.longitude as! Double)
        
        mapView.addAnnotation(annotation)
    }
    
    private func setMapViewRegion() {
        let latitude = NSUserDefaults.standardUserDefaults().valueForKey(Client.UserDefaultsKeys.MapViewCenterLatitude) as! Double
        let longitude = NSUserDefaults.standardUserDefaults().valueForKey(Client.UserDefaultsKeys.MapViewCenterLongitude) as! Double
        let latitudeDelta = NSUserDefaults.standardUserDefaults().valueForKey(Client.UserDefaultsKeys.MapViewSpanLatitudeDelta) as! Double
        let longitudeDelta = NSUserDefaults.standardUserDefaults().valueForKey(Client.UserDefaultsKeys.MapViewSpanLongitudeDelta) as! Double
        
        var region = MKCoordinateRegion()
        
        var span = MKCoordinateSpan()
        span.latitudeDelta = latitudeDelta
        span.longitudeDelta = longitudeDelta
        
        region.span = span
        region.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        mapView.setRegion(region, animated: true)
    }
}