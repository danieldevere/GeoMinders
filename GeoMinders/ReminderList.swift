//
//  ReminderList.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/11/17.
//  Copyright (c) 2017 DANIEL DEVERE. All rights reserved.
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
        name = aDecoder.decodeObject(forKey: "Name") as! String
        checklist = aDecoder.decodeObject(forKey: "Checklist") as! [ReminderItem]
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(checklist, forKey: "Checklist")
    }
    
    override init() {
        checklist = [ReminderItem]()
        name = ""
        super.init()
    }
    
    func countUncheckedItems() -> Int {
        var count = 0
        for item in checklist {
            if !item.checked {
                count += 1
            }
        }
        return count
    }
}
