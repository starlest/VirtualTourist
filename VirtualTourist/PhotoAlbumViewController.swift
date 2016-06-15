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
        attemptToDownloadImages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView!.reloadData()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // Readjust Collection View Layout when the device's orientation is changed
        if flowLayout != nil {
            adjustFlowLayout(size)
            flowLayout.invalidateLayout()
        }
    }
    
    // MARK: Protocols
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as UICollectionViewCell
        addActivityIndicatorToCell(cell)
        Client.sharedInstance().downloadImageFromPhotoDictionaryToCell(photosArray[indexPath.row], cell: cell)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as UICollectionViewCell
        cell.contentView.alpha = 0.5
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }

    // MARK: Actions
    @IBAction func newCollectionButtonPressed(sender: AnyObject) {
        statusLabel.hidden = true
        photosArray.removeAll()
        collectionView!.reloadData()
        attemptToDownloadImages()
    }
}
