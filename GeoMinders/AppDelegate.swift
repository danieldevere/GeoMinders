//
//  AppDelegate.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/5/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let dataModel = DataModel()
    
    let locationManager = CLLocationManager()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let navigationController = window!.rootViewController as! UINavigationController
        let controller = navigationController.topViewController as! AllListsViewController
        dataModel.loadLocationItems()
        locationManager.delegate = self
        dataModel.loadReminderItems()
        controller.dataModel = dataModel
        // Override point for customization after application launch.
        let notificationSettings = UIUserNotificationSettings(types: UIUserNotificationType.alert, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        saveData()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveData()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let alertView = UIAlertController(title: "You have arrived at \(notification.alertTitle)", message: notification.alertBody, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.addAction(alertAction)
        window?.rootViewController?.present(alertView, animated: true, completion: nil)
    }
    
    func saveData() {
        dataModel.saveReminderItems()
        dataModel.saveLocationItems()
    }
    
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
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        dataModel.loadLocationItems()
        dataModel.loadReminderItems()
        var locationEntered = Location()
        let locationID = Int(region.identifier)
        for location in dataModel.locations {
            if location.myID == locationID {
                locationEntered = location
                break
            }
        }
        let date = Date(timeIntervalSinceNow: 5)
        let localNotification = UILocalNotification()
        localNotification.fireDate = date
        localNotification.timeZone = TimeZone.current
        let remindersForNotification = remindersForLocation(locationEntered)
        let additionalReminders = remindersForNotification.count - 1
        var alertString = "You have arried at " + locationEntered.name
        alertString = alertString + ", you need to get \(remindersForNotification[0].reminderText)"
        alertString = alertString + " and \(additionalReminders)"
        localNotification.alertBody = alertString + " other items."
        localNotification.alertTitle = locationEntered.name
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(localNotification)
        print("Entered the location: \(locationEntered.name)")
        
        let navigationController = window?.rootViewController as! UINavigationController
        let controller = navigationController.topViewController as! AllListsViewController
        controller.atStore = true
        let reminderList = ReminderList()
        reminderList.checklist = remindersForNotification
        reminderList.name = "List for " + locationEntered.name
        controller.storeList = reminderList
        print("storelist \(controller.storeList?.checklist.count)")
        controller.tableView.reloadData()
        
      //locationManager.startMonitoringForRegion(region)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("monitoring failed")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
      //  println("didStartMonitoring: \(region.identifier)")
        let locationID = Int(region.identifier)
        for location in dataModel.locations {
            if location.myID == locationID {
         ///       println("didStartMonitoring: \(region.identifier) location: \(location.name) locationID: \(location.myID)")
            }
        }
    }
    
}

