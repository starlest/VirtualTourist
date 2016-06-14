//
//  PhotoAlbumViewController+Helpers.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 14/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import MapKit

extension PhotoAlbumViewController {
    
    // MARK: Map View Helper Methods
    
    func setUpMapView() {
        mapView.addAnnotation(annotation)
        setMapViewRegionAtPin()
        mapView.userInteractionEnabled = false
    }
    
    private func setMapViewRegionAtPin() {
        var region = MKCoordinateRegion()
        let span = zoomMapViewSpan()
        region.span = span
        region.center = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        mapView.setRegion(region, animated: true)
    }
    
    private func zoomMapViewSpan() -> MKCoordinateSpan {
        return MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta / mapViewZoomLevel, longitudeDelta: mapView.region.span.longitudeDelta / mapViewZoomLevel)
    }
    
    // MARK: Collection View Helper Methods
    
    func setUpCollectionView() {
        adjustFlowLayout(self.view.frame.size)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func adjustFlowLayout(size: CGSize) {
        let frameWidth = size.width
        let frameHeight = size.height
        let space: CGFloat = 1.50
        let dimension = frameHeight >= frameWidth ? (frameWidth - (2 * space)) / 3.0 : (frameWidth - (5 * space)) / 6.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    
    // MARK: Utilities
    
    func attemptToDownloadImages() {
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
                    self.statusLabel.text = error?.code == Client.ErrorCodes.NoImages ? "This pin has no images." : "Failed to process request. Please try again later. \n \(error?.code)"
                })
            }
        }
    }
    
    func addActivityIndicatorToCell(cell: UICollectionViewCell) {
        let activityIndicator = UIActivityIndicatorView(frame: cell.bounds)
        activityIndicator.startAnimating()
        activityIndicator.color = UIColor.blueColor()
        cell.contentView.addSubview(activityIndicator)
    }
}