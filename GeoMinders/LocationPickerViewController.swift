//
//  LocationPickerViewController.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/7/17.
//  Copyright (c) 2017 DANIEL DEVERE. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationPickerViewControllerDelegate: class {
    func locationPickerViewControllerDidCancel(_ controller: LocationPickerViewController)
    func locationPickerViewController(_ controller: LocationPickerViewController, didPickLocation location: Location)
}

class LocationPickerViewController: UITableViewController {

    // MARK: - Variables
    
    var dataModel: DataModel!
    var locationID: Int?
    var location: Location?
    var editingLocations = false
    let locationManager = CLLocationManager()
    weak var delegate: LocationPickerViewControllerDelegate?

    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // MARK: - Action functions
    
    // If coming from reminder or reminderDetail screens if user doesn't pick a location
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
        delegate?.locationPickerViewControllerDidCancel(self)
    }
    // Only works coming from settings screen begins deletion process for locations
    func edit() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(LocationPickerViewController.done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(LocationPickerViewController.done))
        tableView.isEditing = true
    }
    // Exits the deletion mode
    func done() {
        tableView.isEditing = false
        editingLocationsView()
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let thisLocation = getLocation() {
            location = thisLocation
        }
        if dataModel == nil {
            print("DataModel not passed to locationPicker")
        }
        if editingLocations {
            editingLocationsView()
        } else {
            pickingLocationView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // User is coming from settings screen and taps a location
        if segue.identifier == "EditLocation" {
            if let indexPath = sender as? IndexPath {
                let editLocation = dataModel.locations[indexPath.row]
                let navigationController = segue.destination as! UINavigationController
                let controller = navigationController.topViewController as! LocationDetailController
                controller.locationID = editLocation.myID
                controller.dataModel = dataModel
            }
        // Segue to the map screen when user selects last row
        } else if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
            if indexPath.row == dataModel.locations.count {
                let navigationController = segue.destination as! UINavigationController
                let controller = navigationController.topViewController as! MapViewController
                controller.locations = dataModel.locations
                controller.delegate = self
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Add a row for the new location cell
        return dataModel.locations.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Load data into location cells
        if indexPath.row < dataModel.locations.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) 
            cell.textLabel?.text = dataModel.locations[indexPath.row].name
            cell.accessoryType = .none
            if let thisLocation = location {
                if thisLocation.myID == dataModel.locations[indexPath.row].myID {
                    cell.accessoryType = .checkmark
                }
            }
            if editingLocations {
                cell.accessoryType = .disclosureIndicator
            }
            return cell
        // Set up the add location cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddLocationButtonCell", for: indexPath) 
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If coming from settings screen segue to location detail when user selects a location
        if editingLocations {
            if indexPath.row < dataModel.locations.count {
                performSegue(withIdentifier: "EditLocation", sender: indexPath)
            }
        }
        // Pick location if coming from the reminder or reminderDetail screens
        if indexPath.row < dataModel.locations.count && delegate != nil {
            location = dataModel.locations[indexPath.row]
            delegate?.locationPickerViewController(self, didPickLocation: location!)
            dismiss(animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        // If tapping the add new location cell
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
 
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        // Switches to delete for all rows except the last one
        if indexPath.row < dataModel.locations.count {
            if tableView.isEditing {
                return UITableViewCellEditingStyle.delete
            }
        }
        return UITableViewCellEditingStyle.none
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Warning alert about deleting locations
        let alertView = UIAlertController(title: "Are you sure?", message: "Deleting a Location also deletes all events at that location", preferredStyle: UIAlertControllerStyle.alert)
        // Alert action completion deletes all reminders associated with location and deletes location
        let alertAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {
            _ in
            for list in self.dataModel.lists {
                list.checklist = list.checklist.filter({
                    $0.locationID != self.dataModel.locations[indexPath.row].myID
                })
            }
            self.dataModel.saveReminderItems()
            self.dataModel.locations.remove(at: indexPath.row)
            self.dataModel.saveLocationItems()
            let indexPaths = [indexPath]
            self.tableView.deleteRows(at: indexPaths, with: .automatic)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertView.addAction(cancelAction)
        alertView.addAction(alertAction)
        present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Functions
    
    // Sets up the buttons for editingLocations mode
    func editingLocationsView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(LocationPickerViewController.edit))
        if dataModel.locations.count == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        title = "My Locations"
        navigationItem.leftBarButtonItem = nil
    }
    // Sets up the buttons for pickingLocation mode
    func pickingLocationView() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(LocationPickerViewController.cancel))
        title = "Choose Location"
    }
    // Convenience method to get the location from location ID (no need for optimization can only have up to 20 locations)
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
}

// MARK: - Map View delegate

extension LocationPickerViewController: MapViewControllerDelegate {
    func mapViewController(_ controller: MapViewController, didTagLocation location: Location) {
        dataModel.locations = controller.locations
        dataModel.saveLocationItems()
        dismiss(animated: true, completion: {
            if !self.editingLocations {
                self.delegate?.locationPickerViewController(self, didPickLocation: location)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}
