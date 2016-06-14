//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    var annotation: MKAnnotation!
    
    let zoomLevel: Double = 200.0
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
    }
    
    // MARK: Actions
}
