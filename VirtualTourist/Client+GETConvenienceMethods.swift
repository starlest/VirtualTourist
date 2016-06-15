//
//  Client+GETConvenienceMethods.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 14/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import Foundation
import UIKit

extension Client {
    
    func downloadLocationPhotosArray(latitude: Double, longitude: Double, completionHandler: (photosArray: [[String:AnyObject]]?, error: NSError?) -> Void) {
        
        let methodParameters: [String:String!] = createSearchByLocationMethodParameters(latitude, longitude: longitude)
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        let task = taskForGetMethod(request: request) { (results, error) in
            
            guard let photosArray = self.attemptToGetPhotosArray(results, error: error, completionHandler: completionHandler) else
            {
                // completion handler was handled in attemptToGetPhotosArray
                return
            }
            
            // Definitely present as already checked in attemptToGetPhotosArray
            let photosDictionary = results[Client.FlickrResponseKeys.Photos] as! [String:AnyObject]
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Client.FlickrResponseKeys.Pages] as? Int else {
                self.sendError("Cannot find key '\(Client.FlickrResponseKeys.Pages)' in \(photosDictionary)", domain: "downloadLocationPhotosArray", completionHandler: completionHandler)
                return
            }
            
            let pageLimit = min(totalPages, 40)

            if pageLimit > 1 {
                self.getAllOtherPagesImages(methodParameters, firstPagePhotosArray: photosArray, pageLimit: pageLimit, completionHandler: completionHandler)
            } else {
                completionHandler(photosArray: photosArray, error: nil)
            }
        }
        
        task.resume()
    }
    
    private func getAllOtherPagesImages(methodParameters: [String:AnyObject], firstPagePhotosArray: [[String:AnyObject]], pageLimit: Int, completionHandler: (photosArray: [[String:AnyObject]]?, error: NSError?) -> Void) {
        
        var allPhotosArray = firstPagePhotosArray
        allPhotosArray.appendContentsOf(firstPagePhotosArray)
        
        // Form a dispatch group to wait for all batch operations to end before proceeding
        let group = dispatch_group_create()
        
        for i in 2...pageLimit {
            dispatch_group_enter(group)
            self.getImagesFromPageNumber(methodParameters, withPageNumber: i, completionHandler: { (photosArray, error) in
                if let photosArray = photosArray {
                    allPhotosArray.appendContentsOf(photosArray)
                }
                dispatch_group_leave(group)
            })
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            
            if allPhotosArray.count == 0 {
                self.sendError("No photos found. Please search again.", domain: "getAllOtherPagesImages", errorCode: Client.ErrorCodes.NoImages, completionHandler: completionHandler)
                return
            }
            
            completionHandler(photosArray: allPhotosArray, error: nil)
            return
        }
    }
    
    // MARK: Helpers
    
    private func createSearchByLocationMethodParameters(latitude: Double, longitude: Double) -> [String:String!] {
        return [
            Client.FlickrParameterKeys.SafeSearch : Client.FlickrParameterValues.UseSafeSearch,
            Client.FlickrParameterKeys.BoundingBox : bboxString(latitude, longitude: longitude),
            Client.FlickrParameterKeys.Extras : Client.FlickrParameterValues.MediumURL,
            Client.FlickrParameterKeys.APIKey : Client.FlickrParameterValues.APIKey,
            Client.FlickrParameterKeys.Method : Client.FlickrParameterValues.SearchMethod,
            Client.FlickrParameterKeys.Format : Client.FlickrParameterValues.ResponseFormat,
            Client.FlickrParameterKeys.Page : "1",
            Client.FlickrParameterKeys.NoJSONCallback : Client.FlickrParameterValues.DisableJSONCallback
        ]
    }
    
    private func bboxString(latitude: Double, longitude: Double) -> String {
        let minimumLon = longitude - Client.Flickr.SearchBBoxHalfWidth
        let minimumLat = latitude - Client.Flickr.SearchBBoxHalfHeight
        let maximumLon = longitude + Client.Flickr.SearchBBoxHalfWidth
        let maximumLat = latitude + Client.Flickr.SearchBBoxHalfHeight
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    private func sendError(errorString: String, domain: String, errorCode: Int = 1, completionHandler: (photosArray: [[String:AnyObject]]?, error: NSError?) -> Void) {
        let userInfo = [NSLocalizedDescriptionKey : errorString]
        completionHandler(photosArray: nil, error: NSError(domain: domain, code: errorCode, userInfo: userInfo))
    }
    
    private func attemptToGetPhotosArray(results: AnyObject!, error: NSError?, completionHandler: (photosArray: [[String:AnyObject]]?, error: NSError?) -> Void) -> [[String:AnyObject]]? {
        /* GUARD: Was there an error? */
        guard error == nil else {
            self.sendError("There was an error encountered.", domain: "attemptToGetPhotosArray", completionHandler: completionHandler)
            return nil
        }
        
        /* GUARD: Are the "photos" and "photo" keys in our result? */
        guard let photosDictionary = results[Client.FlickrResponseKeys.Photos] as? [String:AnyObject], photosArray = photosDictionary["photo"] as? [[String:AnyObject]] else {
            self.sendError("Cannot find keys '\(Client.FlickrResponseKeys.Photos) and '\(Client.FlickrResponseKeys.Photo)' in \(results)", domain: "attemptToGetPhotosArray", completionHandler: completionHandler)
            return nil
        }
        
        if photosArray.count == 0 {
            self.sendError("No photos found. Please search again.", domain: "attemptToGetPhotosArray", errorCode: Client.ErrorCodes.NoImages, completionHandler: completionHandler)
            return nil
        }
        
        return photosArray
    }
    
    private func getImagesFromPageNumber(methodParameters: [String:AnyObject], withPageNumber: Int, completionHandler: (photosArray: [[String:AnyObject]]?, error: NSError?) -> Void) {
        
        var methodParams = methodParameters
        methodParams[Client.FlickrParameterKeys.Page] = "\(withPageNumber)"

        let request = NSURLRequest(URL: flickrURLFromParameters(methodParams))

        let task = taskForGetMethod(request: request) { (results, error) in
            
            if let photosArray = self.attemptToGetPhotosArray(results, error: error, completionHandler: completionHandler)
            {
                completionHandler(photosArray: photosArray, error: nil)
            } else {
                // completion handler was handled attemptToGetPhotosArray
                return
            }
        }
        
        task.resume()
    }
}