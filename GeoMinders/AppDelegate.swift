//
//  AppDelegate.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/5/17.
//  Copyright (c) 2017 DANIEL DEVERE. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let dataModel = DataModel()
    
    let locationManager = CLLocationManager()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize data model on app start
        let navigationController = window!.rootViewController as! UINavigationController
        let controller = navigationController.topViewController as! AllListsViewController
    //    dataModel.loadLocationItems()
        locationManager.delegate = self
     //   dataModel.loadReminderItems()
        controller.dataModel = dataModel
        
        // Set up notification settings
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        saveData()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveData()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        // Configure alert for notification when in app
        let topWindow = UIWindow(frame: UIScreen.main.bounds)
        topWindow.rootViewController = UIViewController()
        topWindow.makeKeyAndVisible()
        if #available(iOS 8.2, *) {
            let alertView = UIAlertController(title: "You have arrived at \(notification.alertTitle!)", message: notification.alertBody, preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                _ in
                topWindow.isHidden = true
            })
            alertView.addAction(alertAction)
            topWindow.rootViewController?.present(alertView, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            let alertView = UIAlertView(title: "You have arrived at a saved location", message: notification.alertBody, delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
    // Convenience method to save both
    func saveData() {
        dataModel.saveReminderItems()
        dataModel.saveLocationItems()
    }
    // Searches lists for all the reminders at a particular location
    func remindersForLocation(_ location: Location) -> [ReminderItem] {
        var reminders = [ReminderItem]()
            for list in dataModel.lists {
                for reminder in list.checklist {
                    if reminder.locationID == location.myID {
                        if !reminder.checked {
                            reminders.append(reminder)
                        }
                        
                    }
                }
            }
        return reminders
    }


}

extension AppDelegate: CLLocationManagerDelegate {
    // Respond to entering geofence
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        dataModel.loadLocationItems()
        dataModel.loadReminderItems()
        var locationEntered = Location()
        let locationID = Int(region.identifier)
        // Search location list for location that matches the ID set for the geofence
        for location in dataModel.locations {
            if location.myID == locationID {
                locationEntered = location
                break
            }
        }
        // Set up the notification
        let date = Date(timeIntervalSinceNow: 1)
        let localNotification = UILocalNotification()
        localNotification.fireDate = date
        localNotification.timeZone = TimeZone.current
        let remindersForNotification = remindersForLocation(locationEntered)
        let additionalReminders = remindersForNotification.count - 1
        var alertString = "You have arried at " + locationEntered.name
        alertString = alertString + ", you need to get \(remindersForNotification[0].reminderText)"
        if additionalReminders > 0 {
            alertString = alertString + " and \(additionalReminders) other items."
        } else {
            alertString = alertString + "."
        }
        localNotification.alertBody = alertString
        if #available(iOS 8.2, *) {
            localNotification.alertTitle = locationEntered.name
        } else {
            // Fallback on earlier versions
        }
        if dataModel.settings.playAlertSounds {
            localNotification.soundName = UILocalNotificationDefaultSoundName
        }
        UIApplication.shared.scheduleLocalNotification(localNotification)
        // Set up second notification if user wants it
        if dataModel.settings.remindAgain {
            let secondDate = Date(timeIntervalSinceNow: 600)
            let secondNotification = UILocalNotification()
            secondNotification.fireDate = secondDate
            secondNotification.timeZone = TimeZone.current
            secondNotification.alertBody = alertString
            if #available(iOS 8.2, *) {
                secondNotification.alertTitle = locationEntered.name
            } else {
                // Fallback on earlier versions
            }
            if dataModel.settings.playAlertSounds {
                secondNotification.soundName = UILocalNotificationDefaultSoundName
            }
            UIApplication.shared.scheduleLocalNotification(secondNotification)
        }
        // Turn on the at store list
        let navigationController = window?.rootViewController as! UINavigationController
        let controller = navigationController.topViewController as! AllListsViewController
        controller.atStore = true
        let reminderList = ReminderList()
        reminderList.checklist = remindersForNotification
        reminderList.name = "List for " + locationEntered.name
        controller.storeList = reminderList
        controller.tableView.reloadData()
    }
    // Turn off the at store list
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let navigationController = window?.rootViewController as! UINavigationController
        let controller = navigationController.topViewController as! AllListsViewController
        controller.storeList = nil
        controller.atStore = false
        controller.tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("monitoring failed")
    }
}

