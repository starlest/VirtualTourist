//
//  Client+Helpers.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 14/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import Foundation
import UIKit

extension Client {
    
    func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: Client.ErrorCodes.FailedToParseData, userInfo: userInfo))
        }
        
        guard let status = parsedResult[Client.FlickrResponseKeys.Status] as? String where status == Client.FlickrResponseValues.OKStatus else {
            let userInfo = [NSLocalizedDescriptionKey : "Flickr API returned an error."]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
            return
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    func downloadImageFromPhotoDictionaryToCell(photoDictionary: [String:AnyObject], cell: UICollectionViewCell) {
        
        addActivityIndicatorToCell(cell)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if let imageUrlString = photoDictionary[Client.FlickrResponseKeys.MediumURL] as? String {
                let image = self.downloadImageFromURL(imageUrlString)
                if let image = image {
                    performUIUpdatesOnMain({
                        let imageView = UIImageView(image: image)
                        cell.contentView.addSubview(imageView)
                    })
                }
            }
        }
    }
    
    private func addActivityIndicatorToCell(cell: UICollectionViewCell) {
        let activityIndicator = UIActivityIndicatorView(frame: cell.bounds)
        activityIndicator.startAnimating()
        activityIndicator.color = UIColor.blueColor()
        cell.contentView.addSubview(activityIndicator)
    }
    
    private func downloadImageFromURL(urlString: String) -> UIImage? {
        let imageURL = NSURL(string: urlString)
        if let imageData = NSData(contentsOfURL: imageURL!) {
            let image = UIImage(data: imageData)
            return image
        }
        return nil
    }
}
