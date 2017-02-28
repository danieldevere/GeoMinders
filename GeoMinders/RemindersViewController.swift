//
//  RemindersViewController.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/5/17.
//  Copyright (c) 2017 DANIEL DEVERE. All rights reserved.
//

import UIKit
import CoreLocation

class RemindersViewController: UITableViewController {
    // MARK: - Variables
    
    var hideCompleted = true
    var reminderList = ReminderList()
    var tempReminder = ReminderItem()
    var dataModel: DataModel!
    var atStore: Bool = false
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var reminderNameLabel: UILabel!
    @IBOutlet weak var reminderDetailLabel: UILabel!
    @IBOutlet weak var reminderCheckbox: UIImageView!
    @IBOutlet weak var showCompletedButton: UIBarButtonItem!
    
    // MARK: - Actions
    
    // User is done typing and presses done on keyboard
    @IBAction func done() {
        let textField = tableView.viewWithTag(1003) as! UITextField
        textField.resignFirstResponder()
        let item = ReminderItem()
        item.reminderText = textField.text!
        item.checked = false
        if UserDefaults.standard.object(forKey: "ReminderIndex") != nil {
            let reminderIndex = UserDefaults.standard.integer(forKey: "ReminderIndex")
            item.myID = reminderIndex + 1
            UserDefaults.standard.set(reminderIndex + 1, forKey: "ReminderIndex")
        } else {
            item.myID = 0
            UserDefaults.standard.set(0, forKey: "ReminderIndex")
        }
        tempReminder = item
        performSegue(withIdentifier: "PickLocation", sender: nil)
    }
    // User presses the show completed/hide completed button
    @IBAction func toggleShowCompleted() {
        hideCompleted = !hideCompleted
        if hideCompleted {
            showCompletedButton.title = "Show Completed"
        } else {
            showCompletedButton.title = "Hide Completed"
        }
        dataModel.sortItemsByCompletedThenDate()
        tableView.reloadData()
    }
    // Changes the left bar button item to the cancel button
    @IBAction func startedTyping() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(RemindersViewController.cancelAdd))
    }
    // User presses the detail button on a reminder
    @IBAction func detailButton(_ sender: AnyObject) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
    // User starts typing reminder but presses cancel button
    func cancelAdd() {
        let textField = tableView.viewWithTag(1003) as! UITextField
        textField.text = ""
        textField.resignFirstResponder()
        navigationItem.leftBarButtonItem = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataModel.sortItemsByCompletedThenDate()
        navigationController?.isToolbarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // User presses the detail button on a reminder
        if segue.identifier == "ShowDetail" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! ReminderItemDetailViewController
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.reminderItem = reminderList.checklist[indexPath.row]
                controller.dataModel = dataModel
                controller.delegate = self
            }
        // User presses done after typing reminder
        } else if segue.identifier == "PickLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationPickerViewController
            controller.delegate = self
            controller.dataModel = dataModel
            controller.editingLocations = false
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculateNumberOfRows()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Adds the new reminder row when the user isn't at the store and they aren't showing the completed items
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewReminderCell", for: indexPath)
            return cell
        } else if indexPath.row - 1 >= 0 && indexPath.row - 1 < reminderList.checklist.count {
            let item = reminderList.checklist[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderItemCell", for: indexPath) 
            let reminderText = cell.viewWithTag(1001) as! UILabel
            let reminderDetailText = cell.viewWithTag(1002) as! UILabel
            reminderText.text = item.reminderText
            reminderDetailText.text = item.detailText
            updateCheckmarkForCell(cell: cell, withReminder: item)
            if atStore {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.detailButton
            }
            return cell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // toggle the cell's checkmark and set the completion date
        if indexPath.row >= 1 {
            let cell = tableView.cellForRow(at: indexPath)
            let checkmark = cell?.viewWithTag(1000) as! UIImageView
            reminderList.checklist[indexPath.row - 1].checked = !reminderList.checklist[indexPath.row - 1].checked
            if reminderList.checklist[indexPath.row - 1].checked {
                checkmark.image = #imageLiteral(resourceName: "checkmark-512")
                removeReminderFromLocation(reminderList.checklist[indexPath.row - 1])
                reminderList.checklist[indexPath.row - 1].completionDate = Date(timeIntervalSinceNow: 0)
                updateLocationMonitoring()
            } else {
                addReminderToLocationCount(reminderList.checklist[indexPath.row - 1])
                updateLocationMonitoring()
                checkmark.image = UIImage()
            }
            tableView.deselectRow(at: indexPath, animated: true)
            dataModel.saveReminderItems()
            dataModel.saveLocationItems()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Prevents deletion of new reminder row
        if indexPath.row == 0 {
            return false
        } else {
            // Allows deletion unless at the store
            if atStore {
                return false
            } else {
                return true
            }
        }
    }
    // Delete reminder. Updates the location's reminder count
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        removeReminderFromLocation(reminderList.checklist[indexPath.row - 1])
        dataModel.saveLocationItems()
        updateLocationMonitoring()
        reminderList.checklist.remove(at: indexPath.row - 1)
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
        dataModel.saveReminderItems()
    }
    // Turns off selection of new reminder cell
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
    // MARK: - Functions
    
    // Convenience function to calculate number of rows
    func calculateNumberOfRows() -> Int {
        var rows = 0
        if !atStore {
            rows += 1
        }
        if hideCompleted {
            var i = 0
            for reminder in reminderList.checklist {
                if !reminder.checked {
                    i += 1
                }
            }
            rows += i
        } else {
            rows += reminderList.checklist.count
        }
        return rows
    }
    // Convenience function for the cell for row at indexpath
    func updateCheckmarkForCell(cell: UITableViewCell, withReminder reminder: ReminderItem) {
        let checkmark = cell.viewWithTag(1000) as! UIImageView
        if reminder.checked {
            checkmark.image = #imageLiteral(resourceName: "checkmark-512")
        } else {
            checkmark.image = UIImage()
        }
    }
    
    func addReminderToLocationCount(_ reminder: ReminderItem) {
        for location in dataModel.locations {
            if location.myID == reminder.locationID {
                location.remindersCount = location.remindersCount + 1
            }
        }
    }
    
    func removeReminderFromLocation(_ reminder: ReminderItem) {
        for location in dataModel.locations {
            if location.myID == reminder.locationID {
                location.remindersCount = location.remindersCount - 1
            }
        }
    }
    
    // MARK: - Location monitoring functions
    
    func region(_ location: Location) -> CLCircularRegion {
        let identifier = "\(location.myID)"
        let region = CLCircularRegion(center: location.coordinate, radius: location.radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    func startMonitoring(_ location: Location) {
        let region = self.region(location)
        locationManager.startMonitoring(for: region)
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
    
    func updateLocationMonitoring() {
        for location in dataModel.locations {
            if location.remindersCount <= 0 {
                stopMonitoring(location)
            } else {
                stopMonitoring(location)
                startMonitoring(location)
            }
        }
    }
}

// MARK: - Reminder Detail Delegate

extension RemindersViewController: ReminderItemDetailViewControllerDelegate {
    
    func reminderItemDetailViewController(_ controller: ReminderItemDetailViewController, didFinishEditingReminder reminder: ReminderItem) {
        dismiss(animated: true, completion: nil)
        updateLocationMonitoring()
        print("After Edit Reminder: \(reminder.reminderText) LocationID: \(reminder.locationID)")
        dataModel.saveReminderItems()
        tableView.reloadData()
        let textField = tableView.viewWithTag(1003) as! UITextField
        if !(textField.text?.isEmpty)! {
            cancelAdd()
        }
    }
    
    func reminderItemDetailViewControllerDidCancel(_ controller: ReminderItemDetailViewController) {
        dismiss(animated: true, completion: nil)
        let textField = tableView.viewWithTag(1003) as! UITextField
        if !(textField.text?.isEmpty)! {
            cancelAdd()
        }
    }
}

// MARK: - Location Picker delegate

extension RemindersViewController: LocationPickerViewControllerDelegate {
    func locationPickerViewController(_ controller: LocationPickerViewController, didPickLocation location: Location) {
        // Add location info to reminder
        tempReminder.detailText = location.name
        tempReminder.locationAddress = location.address
        tempReminder.locationID = location.myID
        tempReminder.creationDate = Date(timeIntervalSinceNow: 0)
        addReminderToLocationCount(tempReminder)
        reminderList.checklist.append(tempReminder)
        dataModel.sortItemsByCompletedThenDate()
        dataModel.saveReminderItems()
        // Update location data
        dataModel.saveLocationItems()
        updateLocationMonitoring()
        // Update view
        cancelAdd()
        tableView.reloadData()
    }
    
    func locationPickerViewControllerDidCancel(_ controller: LocationPickerViewController) {
        let textField = tableView.viewWithTag(1003) as! UITextField
        if !(textField.text?.isEmpty)! {
            textField.becomeFirstResponder()
        }
    }
}


