//
//  Client.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import Foundation

class Client {
    
    // MARK: Properties
    
    let session = NSURLSession.sharedSession()
 
    // MARK: Shared Instance
    static func sharedInstance() -> Client {
        struct Singleton {
            static let sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: GET
    func taskForGetMethod(request request: NSURLRequest, completionHandlerForGet: (results: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(errorString: String, errorCode: Int = 1) {
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForGet(results: nil, error: NSError(domain: "taskForGetMethod", code: errorCode, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2xx response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                var errorCode = ((response as? NSHTTPURLResponse)?.statusCode)!
                
                /* Group 5xx response as server side error under error code 5 */
                if (errorCode >= 500 && errorCode <= 599) {
                    errorCode = errorCode / 100
                }
                
                sendError("Your request returned a status code other than 2xx! \(errorCode)", errorCode: errorCode)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!", errorCode: Client.ErrorCodes.NoDataReturned)
                return
            }
            
            /* Parse the data and use the data (in the completionHandlerForPost) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGet)
        }
        
        return task
    }
}