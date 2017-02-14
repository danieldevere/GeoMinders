//
//  Location.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/7/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import CoreLocation

class Location: NSManagedObject, MKAnnotation {
    @NSManaged var name: String
    @NSManaged var placemark: MKPlacemark?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var radius: Double
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
        var string = stringFromPlacemark()
    //    println("Placemark \(placemark)")

        return stringFromPlacemark()
    }
    
 /*   required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("Name") as! String
        placemark = aDecoder.decodeObjectForKey("Placemark") as? MKPlacemark
        longitude = aDecoder.decodeDoubleForKey("Longitude")
        latitude = aDecoder.decodeDoubleForKey("Latitude")
        radius = aDecoder.decodeDoubleForKey("Radius")
        super.init()
    }

    override init() {
        super.init()
    }
    */
    func stringFromPlacemark() -> String {
        if let placemark = self.placemark {
            return "\(placemark.subThoroughfare) \(placemark.thoroughfare)\n" + "\(placemark.locality), \(placemark.administrativeArea) \(placemark.postalCode)"
        } else {
            return "No Address Found"
        }
        
    }
    /*
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "Name")
        println("Name: \(name)")
        aCoder.encodeObject(placemark, forKey: "Placemark")
        println("Placemark: \(placemark)")
        aCoder.encodeDouble(longitude, forKey: "Longitude")
        println("Longitude: \(longitude)")
        aCoder.encodeDouble(latitude, forKey: "Latitude")
        println("Latitude: \(latitude)")
        aCoder.encodeDouble(radius, forKey: "Radius")
        println("Radius: \(radius)")
    }
    */
    convenience init(name: String, placemark: MKPlacemark?, longitude: Double, latitude: Double) {
        self.init()
        self.name = name
        self.placemark = placemark
        self.longitude = longitude
        self.latitude = latitude
    }

    
}
