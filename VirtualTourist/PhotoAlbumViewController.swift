//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: CoreDataViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var annotation: MKAnnotation!
    var pin: Pin!
    var pinPhotos = [Photo]()
    
    var photosArray: [[String:AnyObject]] = [[String:AnyObject]]()
    
    let mapViewZoomLevel: Double = 2000.0
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStack()
        statusLabel.hidden = true
        setPinAssociatedWithAnnotation()
        setUpMapView()
        setUpCollectionView()
        displayPhotos()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView!.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Save all downloaded images to database
        stack.save()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // Readjust Collection View Layout when the device's orientation is changed
        if flowLayout != nil {
            adjustFlowLayout(size)
            flowLayout.invalidateLayout()
        }
    }

    // MARK: Actions
    
    @IBAction func newCollectionButtonPressed(sender: AnyObject) {
        statusLabel.hidden = true
        pinPhotos.removeAll()
        photosArray.removeAll()
        collectionView!.reloadData()
        attemptToDownloadImages()
    }
}
