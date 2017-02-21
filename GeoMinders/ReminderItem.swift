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
    var creationDate: Date?
    var completionDate: Date?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(reminderText, forKey: "ReminderText")
        aCoder.encode(detailText, forKey: "DetailText")
        aCoder.encode(checked, forKey: "Checked")
        aCoder.encode(locationID, forKey: "LocationID")
        aCoder.encode(myID, forKey: "MyID")
        aCoder.encode(locationAddress, forKey: "LocationAddress")
        aCoder.encode(creationDate, forKey: "CreationDate")
        aCoder.encode(completionDate, forKey: "CompletionDate")
    }
    
    required init(coder aDecoder: NSCoder) {
        reminderText = aDecoder.decodeObject(forKey: "ReminderText") as! String
        detailText = aDecoder.decodeObject(forKey: "DetailText") as! String
        checked = aDecoder.decodeBool(forKey: "Checked")
        myID = aDecoder.decodeInteger(forKey: "MyID")
        locationID = aDecoder.decodeInteger(forKey: "LocationID")
        locationAddress = aDecoder.decodeObject(forKey: "LocationAddress") as! String
        creationDate = aDecoder.decodeObject(forKey: "CreationDate") as? Date
        completionDate = aDecoder.decodeObject(forKey: "CompletionDate") as? Date
        super.init()
    }
    
    override init() {
        super.init()
    }
}
