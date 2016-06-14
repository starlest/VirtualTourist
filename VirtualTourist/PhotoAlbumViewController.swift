//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var statusLabel: UILabel!
    
    var annotation: MKAnnotation!
    
    var photosArray: [[String:AnyObject]] = [[String:AnyObject]]()
    
    let mapViewZoomLevel: Double = 2000.0
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.hidden = true
        setUpMapView()
        adjustFlowLayout(self.view.frame.size)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        Client.sharedInstance().downloadLocationImages(annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { (photosArray, error) in
            if let photosArray = photosArray {
                
                self.photosArray = photosArray
                
                performUIUpdatesOnMain({
                    // Set placeholders for downloading images
                    self.collectionView.reloadData()
                })
                
            } else {
                performUIUpdatesOnMain({ 
                    self.statusLabel.hidden = false
                    if error?.code == Client.ErrorCodes.NoImages {
                        self.statusLabel.text = "This pin has no images."
                    } else {
                        self.statusLabel.text = "Failed to process request. Please try again later. \n \(error?.code)"
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView!.reloadData()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
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
    

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    // MARK: Actions
    
    func addActivityIndicatorToCell(cell: UICollectionViewCell) {
        let activityIndicator = UIActivityIndicatorView(frame: cell.bounds)
        activityIndicator.startAnimating()
        activityIndicator.color = UIColor.blueColor()
        cell.contentView.addSubview(activityIndicator)
    }
    
    func adjustFlowLayout(size: CGSize) {
        let frameWidth = size.width
        let frameHeight = size.height
        let space: CGFloat = 1.50
        let dimension = frameHeight >= frameWidth ? (frameWidth - (2 * space)) / 3.0 : (frameWidth - (5 * space)) / 6.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
}
