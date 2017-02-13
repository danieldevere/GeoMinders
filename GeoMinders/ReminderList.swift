//
//  ReminderList.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/11/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import Foundation

class ReminderList: NSObject, NSCoding {
    var name = ""
    
    var checklist = [ReminderItem]()
    
    init(name: String) {
        self.name = name
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("Name") as! String
        checklist = aDecoder.decodeObjectForKey("Checklist") as! [ReminderItem]
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "Name")
        aCoder.encodeObject(checklist, forKey: "Checklist")
    }
    
    override init() {
        checklist = [ReminderItem]()
        name = ""
        super.init()
    }
}