//
//  LocationPickerViewController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/7/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit

protocol LocationPickerViewControllerDelegate: class {
    func locationPickerViewControllerDidCancel(controller: LocationPickerViewController)
    func locationPickerViewController(controller: LocationPickerViewController, didPickLocationForReminder reminder: ReminderItem)
}

class LocationPickerViewController: UITableViewController {
    
    var locations = [Location]()
    
    var reminderItem: ReminderItem?
    
    weak var delegate: LocationPickerViewControllerDelegate?
    
    @IBAction func cancel() {
  //      dismissViewControllerAnimated(true, completion: nil)
        delegate?.locationPickerViewControllerDidCancel(self)
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let location0 = Location()
        location0.name = "Kroger"
        locations.append(location0)
        
        let location1 = Location()
        location1.name = "Meijer"
        locations.append(location1)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        println("***DID RECEIVE MEMORY WARNING***")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
            if indexPath.row == locations.count {
                let navigationController = segue.destinationViewController as! UINavigationController
                let controller = navigationController.topViewController as! MapViewController
                controller.locations = locations
                
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return locations.count + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < locations.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = locations[indexPath.row].name
            if reminderItem?.location?.name == locations[indexPath.row].name {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddLocationButtonCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < locations.count {
            reminderItem?.location = locations[indexPath.row]
            delegate?.locationPickerViewController(self, didPickLocationForReminder: reminderItem!)
        }
        
    }
    
}


