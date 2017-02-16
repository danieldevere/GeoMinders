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
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) 
        print("Directory: \(paths[0])")
        return paths[0]
    }
    
    func reminderDataFilePath() -> String {
        return reminderDocumentsDirectory().appending("/GeoMindersItems.plist")
      //  return reminderDocumentsDirectory().stringByAppendingPathComponent("GeoMindersItems.plist")
    }
    
    func saveReminderItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(lists, forKey: "Checklists")
        archiver.finishEncoding()
        data.write(toFile: reminderDataFilePath(), atomically: true)
    }
    
    func loadReminderItems() {
        let path = reminderDataFilePath()
        if FileManager.default.fileExists(atPath: path) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                if let checklists = unarchiver.decodeObject(forKey: "Checklists") as? [ReminderList] {
                    lists = checklists
                }
                unarchiver.finishDecoding()
            }
        }
    }
    
    func saveLocationItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(locations, forKey: "MyLocations")
        archiver.finishEncoding()
        data.write(toFile: dataFilePath(), atomically: true)
    }
    
    func loadLocationItems() {
        let path = dataFilePath()
        if FileManager.default.fileExists(atPath: path) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                locations = [Location]()
                
                if let mylocations = unarchiver.decodeObject(forKey: "MyLocations") as? [Location] {
                    locations = mylocations
                }
                unarchiver.finishDecoding()
            }
        }
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) 
        print("Directory: \(paths[0])")
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return documentsDirectory().appending("/GeoMindersLocations.plist")
 //       return documentsDirectory().stringByAppendingPathComponent("GeoMindersLocations.plist")
    }
    
    init() {
        loadLocationItems()
        loadReminderItems()
    }


}
