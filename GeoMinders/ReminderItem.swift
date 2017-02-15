//
//  ReminderItem.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/5/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import Foundation

class ReminderItem: NSObject, NSCoding {
    var checked = false
    var reminderText = ""
    var detailText = ""
    var myID: Int = 0
    var locationID: Int = 0
    var locationAddress = ""
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(reminderText, forKey: "ReminderText")
        aCoder.encodeObject(detailText, forKey: "DetailText")
        aCoder.encodeBool(checked, forKey: "Checked")
        aCoder.encodeInteger(locationID, forKey: "LocationID")
        aCoder.encodeInteger(myID, forKey: "MyID")
        aCoder.encodeObject(locationAddress, forKey: "LocationAddress")
    }
    
    required init(coder aDecoder: NSCoder) {
        reminderText = aDecoder.decodeObjectForKey("ReminderText") as! String
        detailText = aDecoder.decodeObjectForKey("DetailText") as! String
        checked = aDecoder.decodeBoolForKey("Checked")
        myID = aDecoder.decodeIntegerForKey("MyID")
        locationID = aDecoder.decodeIntegerForKey("LocationID")
        locationAddress = aDecoder.decodeObjectForKey("LocationAddress") as! String
        super.init()
    }
    
    override init() {
        super.init()
    }
}