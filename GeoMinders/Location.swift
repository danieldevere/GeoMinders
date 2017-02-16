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
    
    var title: String? {
        if name.isEmpty {
            return placemark?.name
        } else {
            return name
        }
    }
    
    var subtitle: String? {
        return stringFromPlacemark(placemark!)
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        placemark = aDecoder.decodeObject(forKey: "Placemark") as? MKPlacemark
        longitude = aDecoder.decodeDouble(forKey: "Longitude")
        latitude = aDecoder.decodeDouble(forKey: "Latitude")
        radius = aDecoder.decodeDouble(forKey: "Radius")
        reminderIDs = aDecoder.decodeObject(forKey: "ReminderIDs") as! [Int]
        myID = aDecoder.decodeInteger(forKey: "MyID")
        remindersCount = aDecoder.decodeInteger(forKey: "RemindersCount")
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    func stringFromPlacemark(_ placemark: MKPlacemark) -> String {
        var string = ""
        if let subThoroughFare = placemark.subThoroughfare {
            string.append("\(subThoroughFare) ")
        }
        if let thoroughfare = placemark.thoroughfare {
            string.append("\(thoroughfare)\n")
        }
        if let locality = placemark.locality {
            string.append("\(locality), ")
        }
        if let administrativeArea = placemark.administrativeArea {
            string.append("\(administrativeArea) ")
        }
        if let postalCode = placemark.postalCode {
            string.append(postalCode)
        }
        return string
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
     //   println("Name: \(name)")
        aCoder.encode(placemark, forKey: "Placemark")
    //    println("Placemark: \(placemark)")
        aCoder.encode(longitude, forKey: "Longitude")
    //    println("Longitude: \(longitude)")
        aCoder.encode(latitude, forKey: "Latitude")
    //    println("Latitude: \(latitude)")
        aCoder.encode(radius, forKey: "Radius")
   //     println("Radius: \(radius)")
        aCoder.encode(myID, forKey: "MyID")
        aCoder.encode(reminderIDs, forKey: "ReminderIDs")
        aCoder.encode(remindersCount, forKey: "RemindersCount")
    }
    
    convenience init(name: String, placemark: MKPlacemark?, longitude: Double, latitude: Double) {
        self.init()
        self.name = name
        self.placemark = placemark
        self.longitude = longitude
        self.latitude = latitude
        
    }

    
}
