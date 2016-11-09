//
//  MapAnnotation.swift
//  GeoTracker
//
//  Created by CS3714 on 11/9/16.
//  Copyright © 2016 Jesus Fabian. All rights reserved.
//


import UIKit
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    // Instance Variables

    
    var coordinate: CLLocationCoordinate2D  // Geolocation with latitude and longitude
    
    var title:      String?                 // Map annotation title
    
    var subtitle:   String?                 // Map annotation subtitle
    
    
    
    // This function is called to initialize an object instantiated from the MapAnnotation class
    
    init(coordinateGiven: CLLocationCoordinate2D, titleGiven: String, subtitleGiven: String) {
        self.coordinate =   coordinateGiven
        
        self.title      =   titleGiven
        
        self.subtitle   =   subtitleGiven
    }

}
