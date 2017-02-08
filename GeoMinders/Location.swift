//
//  Location.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/7/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class Location: NSObject, NSCoding, MKAnnotation {
    var name = ""
    var placemark: MKPlacemark?
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    var title: String! {
        if name.isEmpty {
            return placemark?.name
        } else {
            return name
        }
    }
    
    var subtitle: String! {
        var string = stringFromPlacemark(placemark!)
        println("Placemark \(placemark)")

        return stringFromPlacemark(placemark!)
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("Name") as! String
        placemark = aDecoder.decodeObjectForKey("Placemark") as? MKPlacemark
        longitude = aDecoder.decodeDoubleForKey("Longitude")
        latitude = aDecoder.decodeDoubleForKey("Latitude")
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        return "\(placemark.subThoroughfare) \(placemark.thoroughfare)\n" + "\(placemark.locality), \(placemark.administrativeArea) \(placemark.postalCode)"
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "Name")
        aCoder.encodeObject(placemark, forKey: "Placemark")
        aCoder.encodeDouble(longitude, forKey: "Longitude")
        aCoder.encodeDouble(latitude, forKey: "Latitude")
    }
    
    convenience init(name: String, placemark: MKPlacemark?, longitude: Double, latitude: Double) {
        self.init()
        self.name = name
        self.placemark = placemark
        self.longitude = longitude
        self.latitude = latitude
    }

    
}
