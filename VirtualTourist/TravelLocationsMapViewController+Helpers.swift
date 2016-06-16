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
    
    // MARK: Helpers
    
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let latitude = roundDouble(newCoordinates.latitude, numberOfPlaces: 10)
            let longitude = roundDouble(newCoordinates.longitude, numberOfPlaces: 10)
    
            if doesPinAlreadyExistsInDatabase(latitude, longitude: longitude) {
                return
            }
            
            let pin = Pin(latitude: latitude, longitude: longitude, context: fetchedResultsController!.managedObjectContext)
            stack.save()
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude as! Double, longitude: pin.longitude as! Double)
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
    }
    
//    The other UILongPressGestureRecognizer states can also be utilized here.
//    To create a drag effect you could do the following for each state:
//    
//    On state .Began , the pin will be created.
//    On state .Changed , At this point you update the first pin coordinates to change the position of the pin
//    On state .Ended , In this state the user has lifted the finger and you are free to persist the pin.
//    In addition the draggable property and mapView(_: annotationView: didChangeDragState: fromOldState: ) could be used.
    
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

    func getPinAssociatedWithAnnotation(annotation: MKAnnotation) -> Pin {
        let sortDescriptors = [
            NSSortDescriptor(key: Globals.PinProperties.Latitude, ascending: true),
            NSSortDescriptor(key: Globals.PinProperties.Longitude, ascending: true)
        ]
        let predicate = NSPredicate(format: "\(Globals.PinProperties.Latitude) == \(annotation.coordinate.latitude) AND \(Globals.PinProperties.Longitude) == \(annotation.coordinate.longitude)")
        performFetchRequest(Globals.Entities.Pin, sortDescriptors: sortDescriptors, predicate: predicate)
        let pin = fetchedResultsController?.fetchedObjects?.first as! Pin
        return pin
    }
    
    func setEditMode() {
        editMode = !editMode
        editButton.title = editMode ? "Done" : "Edit"
        deleteLabel.hidden = !editMode
        mapView.frame.origin.y = editMode ? -50 : 0
        
        // When edit is done, save the changes
        if !editMode {
            stack.save()
        }
    }
}