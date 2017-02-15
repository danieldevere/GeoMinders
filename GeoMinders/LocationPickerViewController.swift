//
//  LocationPickerViewController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/7/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationPickerViewControllerDelegate: class {
    func locationPickerViewControllerDidCancel(controller: LocationPickerViewController)
    func locationPickerViewController(controller: LocationPickerViewController, didPickLocation location: Location)
}

class LocationPickerViewController: UITableViewController {
    
    
    var dataModel: DataModel!
    
    var locationID: Int?
    
    var location: Location?
    
    func getLocation() -> Location? {
        if let thisID = locationID {
            for location in dataModel.locations {
                if location.myID == thisID {
                    return location
                }
            }
        }
        return nil
    }
    let locationManager = CLLocationManager()
    
    weak var delegate: LocationPickerViewControllerDelegate?
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.locationPickerViewControllerDidCancel(self)
        
    }
    
    func edit() {
        editButton.title = "Done"
        tableView.editing = true
        editButton.style = UIBarButtonItemStyle.Done
        
        editButton.action = Selector("done")
    }
    
    func done() {
        tableView.editing = false
        editButton.style = .Plain
        editButton.title = "Edit"
        editButton.action = Selector("edit")
    }
    
        
    

    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.target = self
        editButton.title = "Edit"
        editButton.action = Selector("edit")
        self.navigationItem.rightBarButtonItem = editButton
        if let thisLocation = getLocation() {
            location = thisLocation
        }
        if dataModel == nil {
            println("DataModel not passed to locationPicker")
        }
  /*      let location0 = Location()
        location0.name = "Kroger"
        locations.append(location0)
        
        let location1 = Location()
        location1.name = "Meijer"
        locations.append(location1)
        */
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    //    println("LocationPicker Locations: \(dataModel.locations)")
    }

    override func didReceiveMemoryWarning() {
    //    println("***DID RECEIVE MEMORY WARNING***")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
            if indexPath.row == dataModel.locations.count {
                let navigationController = segue.destinationViewController as! UINavigationController
                let controller = navigationController.topViewController as! MapViewController
                controller.locations = dataModel.locations
                controller.delegate = self
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
      //  println("Number of locations in data model: \(dataModel.locations.count)")
        return dataModel.locations.count + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < dataModel.locations.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = dataModel.locations[indexPath.row].name
            cell.accessoryType = .None
            if let thisLocation = location {
                if thisLocation.myID == dataModel.locations[indexPath.row].myID {
                    cell.accessoryType = .Checkmark
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddLocationButtonCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < dataModel.locations.count && delegate != nil {
            location = dataModel.locations[indexPath.row]
            delegate?.locationPickerViewController(self, didPickLocation: location!)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }
 
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row < dataModel.locations.count {
            if tableView.editing {
                return UITableViewCellEditingStyle.Delete
            }
        }
            return UITableViewCellEditingStyle.None
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let alertView = UIAlertController(title: "Are you sure?", message: "Deleting a Location also deletes all events at that location", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {
            _ in
            for list in self.dataModel.lists {
                let checklistCount = list.checklist.count - 1
                                    
                  /*  if list.checklist[i].locationID == self.dataModel.locations[indexPath.row].myID {
                        list.checklist.removeAtIndex(i)
*/
                        list.checklist = list.checklist.filter({
                            $0.locationID != self.dataModel.locations[indexPath.row].myID
                        })
                    
                
            }
            self.dataModel.saveReminderItems()
            self.dataModel.locations.removeAtIndex(indexPath.row)
            self.dataModel.saveLocationItems()
            let indexPaths = [indexPath]
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        alertView.addAction(cancelAction)
        alertView.addAction(alertAction)
        presentViewController(alertView, animated: true, completion: nil)
        
    }
        
    


    
}

extension LocationPickerViewController: MapViewControllerDelegate {
    func mapViewControllerDidExit(controller: MapViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        dataModel.locations = controller.locations
        dataModel.saveLocationItems()
    }
}



