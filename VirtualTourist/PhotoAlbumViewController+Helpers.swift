//
//  PhotoAlbumViewController+Helpers.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 14/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

import MapKit

extension PhotoAlbumViewController {
    
    func setUpMapView() {
        mapView.addAnnotation(annotation)
        setMapViewRegionAtPin()
        mapView.userInteractionEnabled = false
    }
    
    private func setMapViewRegionAtPin() {
        var region = MKCoordinateRegion()
        let span = zoomMapViewSpan()
        region.span = span
        region.center = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        mapView.setRegion(region, animated: true)
    }
    
    private func zoomMapViewSpan() -> MKCoordinateSpan {
        return MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta / zoomLevel, longitudeDelta: mapView.region.span.longitudeDelta / zoomLevel)
    }
}