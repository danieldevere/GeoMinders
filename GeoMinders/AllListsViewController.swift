//
//  AllListsViewController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/11/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit
import CoreLocation

class AllListsViewController: UITableViewController {
    
    var dataModel: DataModel!
    
    var addingList = false
    
    var atStore = false
    
    var storeList: ReminderList?
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var locationButton: UIBarButtonItem!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    @IBAction func addList() {
        addingList = true
        
        locationButton.target = self
        locationButton.action = #selector(AllListsViewController.cancelNewList)
        addButton.isEnabled = false
        let indexPath = IndexPath(row: dataModel.lists.count, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        locationButton.title = "Cancel"
        let textField = tableView.viewWithTag(3000) as! UITextField
        textField.becomeFirstResponder()
    }
    
    @IBAction func done() {
        let textField = tableView.viewWithTag(3000) as! UITextField
        let newList = ReminderList(name: textField.text!)
        dataModel.lists.append(newList)
        textField.text = ""
        dataModel.saveReminderItems()
        cancelNewList()
    }
    
    func cancelNewList() {
        addingList = false
        locationButton.title = "Locations"
        locationButton.target = self
        locationButton.action = #selector(AllListsViewController.locationButtonAction)
        addButton.isEnabled = true
        tableView.reloadData()
    }
    
    func locationButtonAction() {
        performSegue(withIdentifier: "ShowLocations", sender: nil)
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
   /*
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        for thisRegion in locationManager.monitoredRegions {
            let region = thisRegion as! CLCircularRegion
            if let currentLocation = locationManager.location {
                if (currentLocation.coordinate.latitude == region.center.latitude) && (currentLocation.coordinate.longitude == region.center.longitude) {
                    for location in dataModel.locations {
                        if location.myID == region.identifier.toInt() {
                            storeList?.checklist = remindersForLocation(location)
                            storeList?.name = location.name
                            atStore = true
                            tableView.reloadData()
                            break
                        }
                    }
                    println("found current location in monitored regions")
                    break
                }
                
            } else {
                println("No current location")
            }
        }
        

    }
*/
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! RemindersViewController
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            controller.reminderList = dataModel.lists[indexPath!.row]
            controller.delegate = self
            controller.dataModel = dataModel
            controller.title = dataModel.lists[indexPath!.row].name
          //  println("Sender: \(sender)")
        } else if segue.identifier == "ShowLocations" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationPickerViewController
            controller.dataModel = dataModel
        } else if segue.identifier == "ShowStoreList" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! RemindersViewController
            if let list = storeList {
                print("sent storeList to reminder screen")
                controller.reminderList = list
                controller.title = list.name
            }
            controller.delegate = self
            controller.dataModel = dataModel
            controller.atStore = true
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return numberOfRows()
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < dataModel.lists.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) 
            cell.textLabel?.text = dataModel.lists[indexPath.row].name
            return cell
        } else if (atStore) && (indexPath.row == dataModel.lists.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsToDoAtLocationCell", for: indexPath) 
            cell.textLabel?.text = "\(storeList!.name)"
            cell.detailTextLabel?.text = "\(storeList!.checklist.count) items"
            return cell
        } else if (addingList) && (indexPath.row >= dataModel.lists.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewListCell", for: indexPath) 
            return cell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < dataModel.lists.count {
            return true
        } else {
            return false
        }
    }
    
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
    //    println("Number of locations monitored after list deletion: \(locationManager.monitoredRegions.count)")
    }
    
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


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

extension AllListsViewController: RemindersViewControllerDelegate {
    func remindersViewControllerWantsToSave(_ controller: RemindersViewController) {
        dataModel.saveReminderItems()
    }
}
