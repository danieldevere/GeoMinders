//
//  Location.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/7/17.
//  Copyright (c) 2017 DANIEL DEVERE. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class Location: NSObject, NSCoding, MKAnnotation {
    var myID: Int = 0
    var reminderIDs = [Int]()
    var name = ""
    var addressName = ""
    var address = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var radius: Double = 0.0
    var remindersCount: Int = 0
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    // MKAnnotation Variables
    var title: String? {
        if name.isEmpty {
            return addressName
        } else {
            return name
        }
    }
    
    var subtitle: String? {
        return address
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        address = aDecoder.decodeObject(forKey: "Address") as! String
        addressName = aDecoder.decodeObject(forKey: "AddressName") as! String
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(address, forKey: "Address")
        aCoder.encode(addressName, forKey: "AddressName")
        aCoder.encode(longitude, forKey: "Longitude")
        aCoder.encode(latitude, forKey: "Latitude")
        aCoder.encode(radius, forKey: "Radius")
        aCoder.encode(myID, forKey: "MyID")
        aCoder.encode(reminderIDs, forKey: "ReminderIDs")
        aCoder.encode(remindersCount, forKey: "RemindersCount")
    }
    
    convenience init(name: String, address: String, addressName: String, longitude: Double, latitude: Double) {
        self.init()
        self.name = name
        self.address = address
        self.addressName = addressName
        self.longitude = longitude
        self.latitude = latitude
    }
}
