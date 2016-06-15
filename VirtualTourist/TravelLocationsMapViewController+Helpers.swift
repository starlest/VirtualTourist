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
    
    // MARK: Setup Helper Methods
    
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
        let sortDescriptors = [
            NSSortDescriptor(key: Globals.PinProperties.Latitude, ascending: true),
            NSSortDescriptor(key: Globals.PinProperties.Longitude, ascending: true)
        ]
        
        performFetchRequest(Globals.Entities.Pin, sortDescriptors: sortDescriptors)
        
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
    
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let latitude = roundDouble(newCoordinates.latitude, numberOfPlaces: 10)
        let longitude = roundDouble(newCoordinates.longitude, numberOfPlaces: 10)
        
        // To prevent having multiple pins on the exact location
        if doesPinAlreadyExistsInDatabase(latitude, longitude: longitude) {
            return
        }
        
        let pin = Pin(latitude: latitude, longitude: longitude, context: fetchedResultsController!.managedObjectContext)

        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude as! Double, longitude: pin.longitude as! Double)

        mapView.addAnnotation(annotation)
        
        stack.save()
    }
    
    // To ensure the values saved into CoreData have the same precision
    private func roundDouble(number: Double, numberOfPlaces: Double) -> Double {
        let multiplier = pow(10.0, numberOfPlaces)
        let rounded = round(number * multiplier) / multiplier
        return rounded
    }
    
    private func doesPinAlreadyExistsInDatabase(latitude: Double, longitude: Double) -> Bool {
        let sortDescriptors = [
            NSSortDescriptor(key: Globals.PinProperties.Latitude, ascending: true),
            NSSortDescriptor(key: Globals.PinProperties.Longitude, ascending: true)
        ]
        let predicate = NSPredicate(format: "\(Globals.PinProperties.Latitude) == \(latitude) AND \(Globals.PinProperties.Longitude) == \(longitude)")
        performFetchRequest(Globals.Entities.Pin, sortDescriptors: sortDescriptors, predicate: predicate)
        return fetchedResultsController?.fetchedObjects?.count > 0
    }
    
    private func setMapViewRegion() {
        let latitude = NSUserDefaults.standardUserDefaults().valueForKey(Globals.UserDefaultsKeys.MapViewCenterLatitude) as! Double
        let longitude = NSUserDefaults.standardUserDefaults().valueForKey(Globals.UserDefaultsKeys.MapViewCenterLongitude) as! Double
        let latitudeDelta = NSUserDefaults.standardUserDefaults().valueForKey(Globals.UserDefaultsKeys.MapViewSpanLatitudeDelta) as! Double
        let longitudeDelta = NSUserDefaults.standardUserDefaults().valueForKey(Globals.UserDefaultsKeys.MapViewSpanLongitudeDelta) as! Double
        
        var region = MKCoordinateRegion()
        
        var span = MKCoordinateSpan()
        span.latitudeDelta = latitudeDelta
        span.longitudeDelta = longitudeDelta
        
        region.span = span
        region.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        mapView.setRegion(region, animated: true)
    }
}