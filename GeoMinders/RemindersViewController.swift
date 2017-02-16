//
//  RemindersViewController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/5/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit
import CoreLocation

protocol RemindersViewControllerDelegate: class {
    func remindersViewControllerWantsToSave(_ controller: RemindersViewController)
}

class RemindersViewController: UITableViewController {

    var reminderList: ReminderList
    
    var tempReminder = ReminderItem()
    
    var delegate: RemindersViewControllerDelegate?
    
    var dataModel: DataModel!
    
    var atStore: Bool = false
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var reminderNameLabel: UILabel!
    @IBOutlet weak var reminderDetailLabel: UILabel!
    @IBOutlet weak var reminderCheckbox: UIImageView!
    @IBOutlet weak var backAndCancelButton: UIBarButtonItem!
    
    @IBAction func startedTyping() {
        backAndCancelButton.title = "Cancel"
        backAndCancelButton.action = #selector(RemindersViewController.cancelAdd)
        backAndCancelButton.target = self
    }
    
    func cancelAdd() {
        let textField = tableView.viewWithTag(1003) as! UITextField
        textField.text = ""
        textField.resignFirstResponder()
        backAndCancelButton.title = "< Back"
        backAndCancelButton.action = #selector(RemindersViewController.back)
    }  
    
    @IBAction func done() {
        //   println("Text: \(textField.text)")
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
        textField.text = ""
        
        performSegue(withIdentifier: "PickLocation", sender: nil)

    }

    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func detailButton(_ sender: AnyObject) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
  
    required init(coder aDecoder: NSCoder) {
        reminderList = ReminderList()
        super.init(coder: aDecoder)!
 //       loadReminderItems()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       /* let cellNib = UINib(nibName: "NewReminderCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "NewReminderCell")*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! ReminderItemDetailViewController
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.reminderItem = reminderList.checklist[indexPath.row]
                controller.dataModel = dataModel
                controller.delegate = self
            }
        } else if segue.identifier == "PickLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationPickerViewController
            controller.delegate = self
            controller.dataModel = dataModel
        //    println("Pick Location Segue")
        }
        
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //    println("Number of row: \(reminderList.checklist.count)")
        if atStore {
            return reminderList.checklist.count
        } else {
            return reminderList.checklist.count + 1
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < reminderList.checklist.count {
            let item = reminderList.checklist[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderItemCell", for: indexPath) 
            let reminderText = cell.viewWithTag(1001) as! UILabel
            let reminderDetailText = cell.viewWithTag(1002) as! UILabel
            reminderText.text = item.reminderText
            reminderDetailText.text = item.detailText
            if atStore {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.detailButton
            }
            
            updateCheckmarkForCell(cell, withReminderItem: reminderList.checklist[indexPath.row])
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewReminderCell", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < reminderList.checklist.count {
            reminderList.checklist[indexPath.row].checked = !reminderList.checklist[indexPath.row].checked
            if reminderList.checklist[indexPath.row].checked {
                removeReminderFromLocation(reminderList.checklist[indexPath.row])
                updateLocationMonitoring()
            } else {
                addReminderToLocationCount(reminderList.checklist[indexPath.row])
                updateLocationMonitoring()
            }
            tableView.deselectRow(at: indexPath, animated: true)
            delegate?.remindersViewControllerWantsToSave(self)
            dataModel.saveLocationItems()
    //        saveReminderItems()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if atStore {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        
        removeReminderFromLocation(reminderList.checklist[indexPath.row])
        dataModel.saveLocationItems()
        updateLocationMonitoring()
    //    println("Locations: \(locations[0].reminderIDs.count)")
        reminderList.checklist.remove(at: indexPath.row)
        let indexPaths = [indexPath]

        tableView.deleteRows(at: indexPaths, with: .automatic)
        delegate?.remindersViewControllerWantsToSave(self)
    //    saveReminderItems()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == reminderList.checklist.count {
            return nil
        } else {
            return indexPath
        }
    }
    
  /*
        */
    func updateCheckmarkForCell(_ cell: UITableViewCell, withReminderItem reminder: ReminderItem) {
        let checkmark = cell.viewWithTag(1000) as! UIImageView
        if reminder.checked {
            checkmark.image = UIImage(named: "checkmark-512")
        } else {
            checkmark.image = UIImage()
        }
        
        
    }
    
    func region(_ location: Location) -> CLCircularRegion {
        let identifier = "\(location.myID)"
        let region = CLCircularRegion(center: location.coordinate, radius: location.radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    func startMonitoring(_ location: Location) {
      /*  if locationManager.monitoring {
            print("geofencing not supported")
            return
        }*/
        // 2
        let region = self.region(location)
        locationManager.startMonitoring(for: region)
     //   println("Start monitoring location: \(location.name)")

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
    
    func updateLocationMonitoring() {
        for location in dataModel.locations {
            if location.remindersCount <= 0 {
                stopMonitoring(location)
           //     println("stopped monitoring \(location.name)")
            } else {
                stopMonitoring(location)
                startMonitoring(location)
            }
        }
     //   println("Locations being monitored \(locationManager.monitoredRegions.count)")
    }

    
}



extension RemindersViewController: NewReminderCellDelegate {
    func newReminderCell(_ controller: NewReminderCell, didPressDoneAddingReminder reminder: ReminderItem) {
     //   println("pressedDone")
        tempReminder = reminder
                controller.textField.text = ""
        
        performSegue(withIdentifier: "PickLocation", sender: nil)
    }
    
    func newReminderCellDidCancelWithTap(_ controller: NewReminderCell) {
        
    }
}

extension RemindersViewController: ReminderItemDetailViewControllerDelegate {
    func reminderItemDetailViewController(_ controller: ReminderItemDetailViewController, didFinishEditingReminder reminder: ReminderItem) {
        dismiss(animated: true, completion: nil)
        updateLocationMonitoring()
        print("After Edit Reminder: \(reminder.reminderText) LocationID: \(reminder.locationID)")
        delegate?.remindersViewControllerWantsToSave(self)
        tableView.reloadData()
  //      saveReminderItems()
    }
    
    func reminderItemDetailViewControllerDidCancel(_ controller: ReminderItemDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension RemindersViewController: LocationPickerViewControllerDelegate {
    func locationPickerViewController(_ controller: LocationPickerViewController, didPickLocation location: Location) {
        tempReminder.detailText = location.name
        tempReminder.locationAddress = location.subtitle!
        tempReminder.locationID = location.myID
        addReminderToLocationCount(tempReminder)
        print("After PickLocation Reminder: \(tempReminder.reminderText) LocationID: \(tempReminder.locationID)")
        dataModel.saveLocationItems()
        updateLocationMonitoring()
        reminderList.checklist.append(tempReminder)
        dismiss(animated: true, completion: nil)
        let indexPath = IndexPath(row: reminderList.checklist.count - 1, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        backAndCancelButton.title = "< Back"
        backAndCancelButton.action = #selector(RemindersViewController.back)



        tableView.reloadData()
        delegate?.remindersViewControllerWantsToSave(self)
 //       saveReminderItems()
    }
    
    func locationPickerViewControllerDidCancel(_ controller: LocationPickerViewController) {
     //   dismiss(animated: true, completion: nil)
    }
}


