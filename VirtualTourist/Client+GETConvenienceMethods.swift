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
    
    func downloadLocationImages(latitude: Double, longitude: Double, completionHandler: (photosArray: [[String:AnyObject]]?, error: NSError?) -> Void) {
        
        let methodParameters: [String: String!] = [
            Client.FlickrParameterKeys.SafeSearch : Client.FlickrParameterValues.UseSafeSearch,
            Client.FlickrParameterKeys.BoundingBox : bboxString(latitude, longitude: longitude),
            Client.FlickrParameterKeys.Extras : Client.FlickrParameterValues.MediumURL,
            Client.FlickrParameterKeys.APIKey : Client.FlickrParameterValues.APIKey,
            Client.FlickrParameterKeys.Method : Client.FlickrParameterValues.SearchMethod,
            Client.FlickrParameterKeys.Format : Client.FlickrParameterValues.ResponseFormat,
            Client.FlickrParameterKeys.Page : "40",
            Client.FlickrParameterKeys.NoJSONCallback : Client.FlickrParameterValues.DisableJSONCallback]
        
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))

        let task = taskForGetMethod(request: request) { (results, error) in
            
            func sendError(errorString: String, errorCode: Int = 1) {
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandler(photosArray: nil, error: NSError(domain: "downloadLocationImages", code: errorCode, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard error == nil else {
                completionHandler(photosArray: nil, error: error)
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = results[Client.FlickrResponseKeys.Photos] as? [String:AnyObject], photosArray = photosDictionary["photo"] as? [[String:AnyObject]] else {
                sendError("Cannot find keys '\(Client.FlickrResponseKeys.Photos) and '\(Client.FlickrResponseKeys.Photo)' in \(results)")
                return
            }
            
            if photosArray.count == 0 {
                sendError("No photos found. Please search again.")
                return
            }
            
            completionHandler(photosArray: photosArray, error: nil)
        }
        
        task.resume()
    }
    
    private func bboxString(latitude: Double, longitude: Double) -> String {
        let minimumLon = longitude - Client.Flickr.SearchBBoxHalfWidth
        let minimumLat = latitude - Client.Flickr.SearchBBoxHalfHeight
        let maximumLon = longitude + Client.Flickr.SearchBBoxHalfWidth
        let maximumLat = latitude + Client.Flickr.SearchBBoxHalfHeight
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Client.Flickr.APIScheme
        components.host = Client.Flickr.APIHost
        components.path = Client.Flickr.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
}