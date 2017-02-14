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
    
    lazy var location: Location = {
        for location in self.dataModel.locations {
            if let thisID = self.locationID {
                if location.myID == thisID {
                    return location
                }
            } else {
                return Location()
            }
        }
        println("Error lazy var location didn't work")
        return Location()
    }()
    
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
        editButton.action = Selector("edit")
        self.navigationItem.rightBarButtonItem = editButton
        
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
        println("LocationPicker Locations: \(dataModel.locations)")
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
        return dataModel.locations.count + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < dataModel.locations.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = dataModel.locations[indexPath.row].name
            if location.name == dataModel.locations[indexPath.row].name {
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
        if indexPath.row < dataModel.locations.count && delegate != nil {
            location = dataModel.locations[indexPath.row]
            delegate?.locationPickerViewController(self, didPickLocation: location)
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
        dataModel.locations.removeAtIndex(indexPath.row)
        dataModel.saveLocationItems()
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
        
    func region(#location: Location) -> CLCircularRegion {
        var identifier = "\(location.myID)"
        let region = CLCircularRegion(center: location.coordinate, radius: location.radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        return region
    }
    
    func startMonitoring(location: Location) {
        let region = self.region(location: location)
        locationManager.startMonitoringForRegion(region)
    }
    
    func stopMonitoring(location: Location) {
        for region in locationManager.monitoredRegions {
            if region as? CLCircularRegion == location.name {
                locationManager.stopMonitoringForRegion(region as? CLCircularRegion)
            }
        }
    }



    
}

extension LocationPickerViewController: MapViewControllerDelegate {
    func mapViewControllerDidExit(controller: MapViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        dataModel.locations = controller.locations
        dataModel.saveLocationItems()
    }
}



