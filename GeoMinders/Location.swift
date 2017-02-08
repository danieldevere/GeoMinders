//
//  Location.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/7/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import Foundation
import MapKit

class Location: NSObject, NSCoding {
    var name = ""
    var placemark: MKPlacemark?
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    
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
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "Name")
        aCoder.encodeObject(placemark, forKey: "Placemark")
        aCoder.encodeDouble(longitude, forKey: "Longitude")
        aCoder.encodeDouble(latitude, forKey: "Latitude")
    }

    
}