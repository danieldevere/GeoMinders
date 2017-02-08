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
    func locationPickerViewController(controller: LocationPickerViewController, didPickLocation location: Location)
}

class LocationPickerViewController: UITableViewController {
    
    var locations = [Location]()
    
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

    override func didReceiveMemoryWarning() {
        println("***DID RECEIVE MEMORY WARNING***")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddLocationButtonCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
    }
    
}


