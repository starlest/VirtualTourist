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

            /* GUARD: Was there an error? */
            guard error == nil else {
                self.sendError("There was an error encountered.", domain: "downloadLocationPhotosArray", completionHandler: completionHandler)
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = results[Client.FlickrResponseKeys.Photos] as? [String:AnyObject], photosArray = photosDictionary[Client.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                self.sendError("Cannot find keys '\(Client.FlickrResponseKeys.Photos) and '\(Client.FlickrResponseKeys.Photo)' in \(results)", domain: "attemptToGetPhotosArray", completionHandler: completionHandler)
                return
            }
            
            if photosArray.count == 0 {
                self.sendError("No photos found. Please search again.", domain: "downloadLocationPhotosArray", errorCode: Client.ErrorCodes.NoImages, completionHandler: completionHandler)
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Client.FlickrResponseKeys.Pages] as? Int else {
                self.sendError("Cannot find key '\(Client.FlickrResponseKeys.Pages)' in \(photosDictionary)", domain: "downloadLocationPhotosArray", completionHandler: completionHandler)
                return
            }
            
            let pageLimit = min(totalPages, 191)
            let page = Int(arc4random()) % pageLimit + 1
            
            self.getImagesFromPageNumber(methodParameters, withPageNumber: page, completionHandler: { (photosArray, error) in
                
                /* GUARD: Was there an error? */
                guard error == nil else {
                    self.sendError("There was an error encountered.", domain: "downloadLocationPhotosArray", completionHandler: completionHandler)
                    return
                }
                
                print(photosArray!.count)
                completionHandler(photosArray: photosArray, error: nil)
            })
        }
        
        task.resume()
    }
    
    // MARK: downloadLocationPhotosArray Helpers
    private func getImagesFromPageNumber(methodParameters: [String:AnyObject], withPageNumber: Int, completionHandler: (photosArray: [[String:AnyObject]]?, error: NSError?) -> Void) {
        
        var methodParams = methodParameters
        methodParams[Client.FlickrParameterKeys.Page] = "\(withPageNumber)"
        
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParams))
        
        let task = taskForGetMethod(request: request) { (results, error) in
            
            /* GUARD: Was there an error? */
            guard error == nil else {
                self.sendError("There was an error encountered.", domain: "getImagesFromPageNumber", completionHandler: completionHandler)
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = results[Client.FlickrResponseKeys.Photos] as? [String:AnyObject], photosArray = photosDictionary[Client.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                self.sendError("Cannot find keys '\(Client.FlickrResponseKeys.Photos) and '\(Client.FlickrResponseKeys.Photo)' in \(results)", domain: "getImagesFromPageNumber", completionHandler: completionHandler)
                return
            }
            
            if photosArray.count == 0 {
                self.sendError("No photos found. Please search again.", domain: "getImagesFromPageNumber", errorCode: Client.ErrorCodes.NoImages, completionHandler: completionHandler)
                return
            }
            
            completionHandler(photosArray: photosArray, error: nil)
        }
        
        task.resume()
    }

    // MARK: Utilities
    
    private func createSearchByLocationMethodParameters(latitude: Double, longitude: Double) -> [String:String!] {
        return [
            Client.FlickrParameterKeys.SafeSearch : Client.FlickrParameterValues.UseSafeSearch,
            Client.FlickrParameterKeys.BoundingBox : bboxString(latitude, longitude: longitude),
            Client.FlickrParameterKeys.Extras : Client.FlickrParameterValues.MediumURL,
            Client.FlickrParameterKeys.APIKey : Client.FlickrParameterValues.APIKey,
            Client.FlickrParameterKeys.Method : Client.FlickrParameterValues.SearchMethod,
            Client.FlickrParameterKeys.Format : Client.FlickrParameterValues.ResponseFormat,
            Client.FlickrParameterKeys.PerPage : "21",
            Client.FlickrParameterKeys.Page : "1",
            Client.FlickrParameterKeys.NoJSONCallback : Client.FlickrParameterValues.DisableJSONCallback
        ]
    }
    
    private func bboxString(latitude: Double, longitude: Double) -> String {
        let minimumLon = max(longitude - Client.Flickr.SearchBBoxHalfWidth, Client.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Client.Flickr.SearchBBoxHalfHeight, Client.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Client.Flickr.SearchBBoxHalfWidth, Client.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Client.Flickr.SearchBBoxHalfHeight, Client.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    private func sendError(errorString: String, domain: String, errorCode: Int = 1, completionHandler: (photosArray: [[String:AnyObject]]?, error: NSError?) -> Void) {
        let userInfo = [NSLocalizedDescriptionKey : errorString]
        completionHandler(photosArray: nil, error: NSError(domain: domain, code: errorCode, userInfo: userInfo))
    }
}