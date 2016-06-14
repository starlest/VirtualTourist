//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 13/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mapView: MKMapView?
    let stack = CoreDataStack(modelName: "Model")!
    
    func checkIfFirstLaunch() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(Globals.UserDefaultsKeys.HasLaunchedBefore) {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: Globals.UserDefaultsKeys.HasLaunchedBefore)
            NSUserDefaults.standardUserDefaults().setDouble(0.0, forKey: Globals.UserDefaultsKeys.MapViewCenterLatitude)
            NSUserDefaults.standardUserDefaults().setDouble(0.0, forKey: Globals.UserDefaultsKeys.MapViewCenterLongitude)
            NSUserDefaults.standardUserDefaults().setDouble(126.0, forKey: Globals.UserDefaultsKeys.MapViewSpanLatitudeDelta)
            NSUserDefaults.standardUserDefaults().setDouble(180.0, forKey: Globals.UserDefaultsKeys.MapViewSpanLongitudeDelta)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func saveMapViewState() {
        if let mapView = mapView {
            NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.latitude, forKey: Globals.UserDefaultsKeys.MapViewCenterLatitude)
            NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.longitude, forKey: Globals.UserDefaultsKeys.MapViewCenterLongitude)
            NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: Globals.UserDefaultsKeys.MapViewSpanLatitudeDelta)
            NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: Globals.UserDefaultsKeys.MapViewSpanLongitudeDelta)
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        checkIfFirstLaunch()
        stack.autoSave(60)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        stack.save()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        saveMapViewState()
        stack.save()
    }

    func applicationWillTerminate(application: UIApplication) {
    }
}

