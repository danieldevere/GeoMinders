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
    var myID: Int = 0
    var reminderIDs = [Int]()
    var name = ""
    var placemark: MKPlacemark?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var radius: Double = 0.0
    var remindersCount: Int = 0
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
        return stringFromPlacemark(placemark!)
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("Name") as! String
        placemark = aDecoder.decodeObjectForKey("Placemark") as? MKPlacemark
        longitude = aDecoder.decodeDoubleForKey("Longitude")
        latitude = aDecoder.decodeDoubleForKey("Latitude")
        radius = aDecoder.decodeDoubleForKey("Radius")
        reminderIDs = aDecoder.decodeObjectForKey("ReminderIDs") as! [Int]
        myID = aDecoder.decodeIntegerForKey("MyID")
        remindersCount = aDecoder.decodeIntegerForKey("RemindersCount")
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    func stringFromPlacemark(placemark: MKPlacemark) -> String {
        return "\(placemark.subThoroughfare) \(placemark.thoroughfare)\n" + "\(placemark.locality), \(placemark.administrativeArea) \(placemark.postalCode)"
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "Name")
     //   println("Name: \(name)")
        aCoder.encodeObject(placemark, forKey: "Placemark")
    //    println("Placemark: \(placemark)")
        aCoder.encodeDouble(longitude, forKey: "Longitude")
    //    println("Longitude: \(longitude)")
        aCoder.encodeDouble(latitude, forKey: "Latitude")
    //    println("Latitude: \(latitude)")
        aCoder.encodeDouble(radius, forKey: "Radius")
   //     println("Radius: \(radius)")
        aCoder.encodeInteger(myID, forKey: "MyID")
        aCoder.encodeObject(reminderIDs, forKey: "ReminderIDs")
        aCoder.encodeInteger(remindersCount, forKey: "RemindersCount")
    }
    
    convenience init(name: String, placemark: MKPlacemark?, longitude: Double, latitude: Double) {
        self.init()
        self.name = name
        self.placemark = placemark
        self.longitude = longitude
        self.latitude = latitude
        
    }

    
}
