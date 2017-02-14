//
//  ReminderItem.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/5/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ReminderItem: NSManagedObject {
    @NSManaged var checked: Bool
    @NSManaged var reminderText: String
    @NSManaged var detailText: String
    @NSManaged var location: Location?
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(reminderText, forKey: "ReminderText")
        aCoder.encodeObject(detailText, forKey: "DetailText")
        aCoder.encodeBool(checked, forKey: "Checked")
        aCoder.encodeObject(location, forKey: "Location")
    }
  /*
    required init(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        reminderText = aDecoder.decodeObjectForKey("ReminderText") as! String
        detailText = aDecoder.decodeObjectForKey("DetailText") as! String
        checked = aDecoder.decodeBoolForKey("Checked")
        location = aDecoder.decodeObjectForKey("Location") as? Location
        super.init()
    }
    
    override init() {
        super.init()
    }*/
}