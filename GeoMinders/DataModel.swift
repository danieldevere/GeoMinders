//
//  DataModel.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/14/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import Foundation

class DataModel {
    var lists = [ReminderList]()
    
    var locations = [Location]()
    
    func reminderDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
        println("Directory: \(paths[0])")
        return paths[0]
    }
    
    func reminderDataFilePath() -> String {
        return reminderDocumentsDirectory().stringByAppendingPathComponent("GeoMindersItems.plist")
    }
    
    func saveReminderItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(lists, forKey: "Checklists")
        archiver.finishEncoding()
        data.writeToFile(reminderDataFilePath(), atomically: true)
    }
    
    func loadReminderItems() {
        let path = reminderDataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                if let checklists = unarchiver.decodeObjectForKey("Checklists") as? [ReminderList] {
                    lists = checklists
                }
                unarchiver.finishDecoding()
            }
        }
    }
    
    func saveLocationItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(locations, forKey: "MyLocations")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadLocationItems() {
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                locations = [Location]()
                var location = Location()
                
                if let mylocations = unarchiver.decodeObjectForKey("MyLocations") as? [Location] {
                    locations = mylocations
                }
                unarchiver.finishDecoding()
            }
        }
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
        println("Directory: \(paths[0])")
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return documentsDirectory().stringByAppendingPathComponent("GeoMindersLocations.plist")
    }
    
    init() {
        loadLocationItems()
        loadReminderItems()
    }


}