//
//  PhotoAlbumViewController+CollectionView.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 15/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import UIKit

extension PhotoAlbumViewController {
    
    // MARK: Protocols
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count == 0 ? pinPhotos.count : photosArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Globals.CellIdentifier, forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        cell.imageView.image = nil
        cell.imageView.alpha = cell.selected ? 0.5 : 1.0
        
        if let photo = pinPhotos[safe: indexPath.row] {
            setCellImageWithPhoto(cell, photo: photo)
            cell.activityIndicatorView.stopAnimating()
        } else {
            cell.activityIndicatorView.startAnimating()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
        
        /* GUARD: Disallow selection if image is still downloading */
        guard let photo = pinPhotos[safe: indexPath.row] else {
            collectionView.deselectItemAtIndexPath(indexPath, animated: false)
            return
        }

        if collectionView.indexPathsForSelectedItems()?.count == 1 {
            newCollectionButton.title = "Remove Selected Pictures"
            selectionDeletionMode = true
        }

        cell.imageView.alpha = 0.5
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.indexPathsForSelectedItems()?.count == 0 {
            newCollectionButton.title = "New Collection"
            selectionDeletionMode = false
        }
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
        cell.imageView.alpha = 1.0
    }
    
    // MARK: Collection View Helper Methods
    
    func setUpCollectionView() {
        adjustFlowLayout(self.view.frame.size)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
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
    
    func addActivityIndicatorToCell(activityIndicator: UIActivityIndicatorView, cell: UICollectionViewCell) {
        activityIndicator.startAnimating()
        activityIndicator.color = UIColor.blueColor()
        cell.contentView.addSubview(activityIndicator)
    }
}