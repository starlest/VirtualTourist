//
//  Globals.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

class Globals {
    
    static let CellIdentifier = "PhotoCell"
    
    // MARK: UserDefaults Keys
    struct UserDefaultsKeys {
        static let HasLaunchedBefore = "HasLaunchedBefore"
        static let MapViewZoomLevel = "MapViewZoomLevel"
        static let MapViewCenterLatitude = "MapViewCenterLatitude"
        static let MapViewCenterLongitude = "MapViewCenterLongitude"
        static let MapViewSpanLatitudeDelta = "MapViewSpanLatitudeDelta"
        static let MapViewSpanLongitudeDelta = "MapViewSpanLongitudeDelta"
    }
    
    // MARK: Entities
    struct Entities {
        static let Pin = "Pin"
        static let Photo = "Photo"
    }
    
    // MARK: Pin Properties
    struct PinProperties {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
}