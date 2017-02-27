//
//  AllListsViewController.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/11/17.
//  Copyright (c) 2017 DANIEL DEVERE. All rights reserved.
//

import UIKit
import CoreLocation

class AllListsViewController: UITableViewController {
    
    // MARK: - Variables
    
    var dataModel: DataModel!
    var addingList = false
    var atStore = false
    var storeList: ReminderList?
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!

    // MARK: - Action Functions
    
    // User presses the plus button
    @IBAction func addList() {
        addingList = true
        settingsButton.target = self
        settingsButton.action = #selector(AllListsViewController.cancelNewList)
        addButton.isEnabled = false
        let indexPath = IndexPath(row: dataModel.lists.count, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        settingsButton.title = "Cancel"
        let textField = tableView.viewWithTag(3000) as! UITextField
        textField.becomeFirstResponder()
    }
    // User presses done on keyboard to add new list
    @IBAction func done() {
        let textField = tableView.viewWithTag(3000) as! UITextField
        let newList = ReminderList(name: textField.text!)
        dataModel.lists.append(newList)
        textField.text = ""
        dataModel.saveReminderItems()
        cancelNewList()
    }
    // User presses cancel while adding new list
    func cancelNewList() {
        let textField = tableView.viewWithTag(3000) as! UITextField
        textField.text = ""
        textField.resignFirstResponder()
        addingList = false
        settingsButton.target = self
        settingsButton.action = #selector(AllListsViewController.settingsButtonAction)
        settingsButton.title = "Settings"
        addButton.isEnabled = true
        tableView.reloadData()
    }
    // User presses settings button
    func settingsButtonAction() {
        performSegue(withIdentifier: "ShowSettings", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.target = self
        settingsButton.action = #selector(AllListsViewController.settingsButtonAction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segue when user taps on reminder list
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! RemindersViewController
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            controller.reminderList = dataModel.lists[indexPath!.row]
            controller.dataModel = dataModel
            controller.title = "\(dataModel.lists[indexPath!.row].name) List"
            if addingList {
                cancelNewList()
            }
        // Segue when user taps on settings button
        } else if segue.identifier == "ShowSettings" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! SettingsViewController
            controller.dataModel = dataModel
        // Segue when user is at store and taps the store list
        } else if segue.identifier == "ShowStoreList" {
            let controller = segue.destination as! RemindersViewController
            if let list = storeList {
                print("sent storeList to reminder screen")
                controller.reminderList = list
                controller.title = list.name
            }
            controller.dataModel = dataModel
            controller.atStore = true
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // List cells
        if indexPath.row < dataModel.lists.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) 
            cell.textLabel?.text = dataModel.lists[indexPath.row].name
            return cell
        // New list cell below list cells if not at store and below store list if at store
        } else if (addingList) && (indexPath.row == dataModel.lists.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewListCell", for: indexPath) 
            return cell
        // Add store list below list cells
        } else if (atStore) && (indexPath.row == numberOfRows() - 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsToDoAtLocationCell", for: indexPath)
            cell.textLabel?.text = "\(storeList!.name)"
            cell.detailTextLabel?.text = "\(storeList!.checklist.count) items"
            return cell
        }else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Alert user before list deletion
        let alert = UIAlertController(title: "Deleting List", message: "This will delete all the items in the list", preferredStyle: UIAlertControllerStyle.alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {
            _ in
            self.listDeleted(indexPath.row)
            self.dataModel.lists.remove(at: indexPath.row)
            let indexPaths = [indexPath]
            tableView.deleteRows(at: indexPaths, with: .automatic)
            self.dataModel.saveReminderItems()
        })
        alert.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    // Cancels new list if there is one.  storyboard has segue to reminder list
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if addingList {
            if atStore && indexPath.row > dataModel.lists.count + 1 {
                cancelNewList()
            } else if !atStore && indexPath.row > dataModel.lists.count {
                cancelNewList()
            }
        }
    }
    // Don't allow editing of new cell or store list
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < dataModel.lists.count {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Location monitoring functions
    
    // Update all the locations when a list is deleted
    func listDeleted(_ listIndex: Int) {
        for item in dataModel.lists[listIndex].checklist {
            for location in dataModel.locations {
                if location.myID == item.locationID {
                    location.remindersCount -= 1
                }
            }
        }
        dataModel.saveLocationItems()
        updateLocationMonitoring()
    }
    // Check all the locations to see if they should still be monitored
    func updateLocationMonitoring() {
        for location in dataModel.locations {
            if location.remindersCount <= 0 {
                stopMonitoring(location)
            }
        }
    }
    
    func stopMonitoring(_ location: Location) {
        for region in locationManager.monitoredRegions {
            if let region = region as? CLCircularRegion {
                if Int(region.identifier) == location.myID {
                    locationManager.stopMonitoring(for: region)
                }
            }
        }
    }
    
    // MARK: - Functions
    
    // Search reminders to create at store list
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
    // Calculate the number of rows in the tableview
    func numberOfRows() -> Int {
        var number = dataModel.lists.count
        if addingList {
            number += 1
        }
        if atStore {
            number += 1
        }
        return number
    }
}
