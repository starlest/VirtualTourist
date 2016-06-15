//
//  PhotoAlbumViewController+Helpers.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 14/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import MapKit

extension PhotoAlbumViewController {
    
    func displayPhotos() {
        if pin.photos?.count == 0 {
            attemptToDownloadImages()
        } else {
            pinPhotos = pin.photos?.allObjects as! [Photo]
            collectionView.reloadData()
        }
    }
    
    func setPinAssociatedWithAnnotation() {
        let sortDescriptors = [
            NSSortDescriptor(key: Globals.PinProperties.Latitude, ascending: true),
            NSSortDescriptor(key: Globals.PinProperties.Longitude, ascending: true)
        ]
        let predicate = NSPredicate(format: "\(Globals.PinProperties.Latitude) == \(annotation.coordinate.latitude) AND \(Globals.PinProperties.Longitude) == \(annotation.coordinate.longitude)")
        performFetchRequest(Globals.Entities.Pin, sortDescriptors: sortDescriptors, predicate: predicate)
        pin = fetchedResultsController?.fetchedObjects?.first as! Pin
        pinPhotos.appendContentsOf(pin.photos?.allObjects as! [Photo])
    }
    
    func attemptToDownloadImages() {
        Client.sharedInstance().downloadLocationPhotosArray(annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { (photosArray, error) in
            if let photosArray = photosArray {
                self.photosArray = photosArray
                performUIUpdatesOnMain({
                    // Set placeholders for downloading images
                    self.collectionView.reloadData()
                })
                self.downloadPhotosArrayImagesInBackground()

            } else {
                performUIUpdatesOnMain({
                    self.statusLabel.hidden = false
                    self.statusLabel.text = error?.code == Client.ErrorCodes.NoImages ? "This pin has no images." : "Failed to process request. Please try again later. \n \(error?.code)"
                })
            }
        }
    }
    
    func downloadPhotosArrayImagesInBackground() {
        
        performOperationsInBackground({
            for photoDictionary in self.photosArray {
                
                if let image = Client.sharedInstance().downloadImageFromPhotoDictionary(photoDictionary) {
                    let photo = Photo(photoData: UIImagePNGRepresentation(image)!, pin: self.pin, context: self.stack.context)
                    self.pinPhotos.append(photo)
                
                    // Only display images on visible cells of the collection view
                    let indexPath = NSIndexPath(forRow: self.pinPhotos.count - 1, inSection: 0)
                    if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? PhotoAlbumCollectionViewCell {
                        performUIUpdatesOnMain({
                            cell.imageView.image = nil
                            self.setCellImageWithPhoto(cell, photo: photo)
                        })
                    }
                }
            }
        })
    }
    
    func setCellImageWithPhoto(cell: PhotoAlbumCollectionViewCell, photo: Photo) {
        let image = UIImage(data: photo.imageData!)
        cell.imageView.image = image
        cell.activityIndicatorView.stopAnimating()
    }
}