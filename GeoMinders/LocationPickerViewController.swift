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
    
    var locations = [Location]()
    
    var location: Location?
    
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
    
    required init!(coder aDecoder: NSCoder!) {
        locations = [Location]()
        super.init(coder: aDecoder)
        loadLocationItems()
        println("required init")
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
        println("LocationPicker Locations: \(locations)")
    }

    override func didReceiveMemoryWarning() {
    //    println("***DID RECEIVE MEMORY WARNING***")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
            if indexPath.row == locations.count {
                let navigationController = segue.destinationViewController as! UINavigationController
                let controller = navigationController.topViewController as! MapViewController
                controller.locations = locations
                controller.delegate = self
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
            if location?.name == locations[indexPath.row].name {
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
        if indexPath.row < locations.count && delegate != nil {
            location = locations[indexPath.row]
            delegate?.locationPickerViewController(self, didPickLocation: location!)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }
 
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row < locations.count {
            if tableView.editing {
                return UITableViewCellEditingStyle.Delete
            }
        }
            return UITableViewCellEditingStyle.None
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        locations.removeAtIndex(indexPath.row)
        saveLocationItems()
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    func saveLocationItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(locations, forKey: "MyLocations")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadLocationItems() {
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                locations = [Location]()
                var location = Location()
                
                if let mylocations = unarchiver.decodeObjectForKey("MyLocations") as? [Location] {
                    locations = mylocations
                }
                unarchiver.finishDecoding()
            }
        }
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
        println("Directory: \(paths[0])")
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return documentsDirectory().stringByAppendingPathComponent("GeoMindersLocations.plist")
    }
    
    func region(#location: Location) -> CLCircularRegion {
        let region = CLCircularRegion(center: location.coordinate, radius: location.radius, identifier: location.name)
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
        locations = controller.locations
        saveLocationItems()
    }
}



