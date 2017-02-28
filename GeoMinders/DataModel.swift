//
//  DataModel.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/14/17.
//  Copyright (c) 2017 DANIEL DEVERE. All rights reserved.
//

import Foundation

class DataModel {
    
    init() {
        loadLocationItems()
        loadReminderItems()
        loadSettings()
        registerDefaults()
        handleFirstTime()
    }
    
    // MARK: - Settings Data
    
    var settings = Settings(remindAgain: true, playAlertSounds: true, deleteAfter30Days: true)
    
    func settingsDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("Settings Directory: \(paths[0])")
        return paths[0]
    }
    
    func settingsDataFilePath() -> String {
        return settingsDocumentsDirectory().appending("/GeoMindersSettings.plist")
    }
    
    func saveSettings() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(settings, forKey: "Settings")
        archiver.finishEncoding()
        data.write(toFile: settingsDataFilePath(), atomically: true)
    }
    
    func loadSettings() {
        let path = settingsDataFilePath()
        if FileManager.default.fileExists(atPath: path) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                if let loadedSettings = unarchiver.decodeObject(forKey: "Settings") as? Settings {
                    settings = loadedSettings
                    unarchiver.finishDecoding()
                }
            }
        }
    }

    // MARK: - Reminders Data
    
    var lists = [ReminderList]()
    
    func reminderDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("Reminder Directory: \(paths[0])")
        return paths[0]
    }
    
    func reminderDataFilePath() -> String {
        return reminderDocumentsDirectory().appending("/GeoMindersItems.plist")
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
                    unarchiver.finishDecoding()
                    if settings.deleteAfter30Days {
                        deleteOldCompleted()
                    }
                    sortItemsByCompletedThenDate()
                }
            }
        }
    }
    
    func deleteOldCompleted() {
        for list in lists {
            let checkedList = list.checklist.filter({
                $0.checked == true
            })
            var uncheckedList = list.checklist.filter({
                $0.checked == false
            })
            let keepers = checkedList.filter({
                Date(timeIntervalSinceNow: 0).timeIntervalSince($0.completionDate!) < (30 * 24 * 60 * 60)
            })
            for keeper in keepers {
                uncheckedList.append(keeper)
            }
            list.checklist = uncheckedList
        }
    }
    
    func sortItemsByCompletedThenDate() {
        for list in lists {
            var completed = list.checklist.filter({
                $0.checked == true
            })
            var notCompleted = list.checklist.filter({
                $0.checked == false
            })
            completed.sort(by: {
                item1, item2 in return
                item1.creationDate?.compare(item2.creationDate!) == .orderedAscending
            })
            notCompleted.sort(by: {
                item1, item2 in return
                item1.creationDate?.compare(item2.creationDate!) == .orderedAscending
            })
            var sortedList = [ReminderItem]()
            for item in notCompleted {
                sortedList.append(item)
            }
            for item in completed {
                sortedList.append(item)
            }
            list.checklist = sortedList
        }
    }
    
    // MARK: - Location Data
    
    var locations = [Location]()
    
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
                    unarchiver.finishDecoding()
                }
            }
        }
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) 
        print("Locations Directory: \(paths[0])")
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return documentsDirectory().appending("/GeoMindersLocations.plist")
    }
    
    // MARK: - Defaults
    
    var indexOfSelectedChecklist: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
            UserDefaults.standard.synchronize()
        }
    }
    
    func registerDefaults() {
        let dictionary = [ "ChecklistIndex": -1, "FirstTime": true, "LocationIndex": 0 ] as [String : Any]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    // MARK: - First Time Function
    
    func handleFirstTime() {
        let firstTime = UserDefaults.standard.bool(forKey: "FirstTime")
        if firstTime {
            let checklist = ReminderList(name: "Reminders")
            lists.append(checklist)
            indexOfSelectedChecklist = 0
            UserDefaults.standard.set(false, forKey: "FirstTime")
        }
    }
}
