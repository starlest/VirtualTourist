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
    
    // MARK: Protocols
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        controller.annotation = view.annotation
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Actions
    
    @IBAction func editButtonPressed(sender: AnyObject) {
    }
    
    // MARK: Helpers
    
    func setUpMapView() {
        mapView.delegate = self
        setUpMapViewGestureRecognizer()
        setMapViewRegion()
        
        // Reference mapView in appDelegate so that its state 
        // could be saved when the app closes or goes into the background
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mapView = mapView
    }
    
    private func setUpMapViewGestureRecognizer() {
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

