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
    
    func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
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
    
    func downloadImageFromPhotoDictionary(photoDictionary: [String:AnyObject]) -> UIImage? {
        if let imageUrlString = photoDictionary[Client.FlickrResponseKeys.MediumURL] as? String {
            let image = self.downloadImageFromURL(imageUrlString)
            return image
        }
        return nil
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
