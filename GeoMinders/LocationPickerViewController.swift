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
    func locationPickerViewControllerDidCancel(_ controller: LocationPickerViewController)
    func locationPickerViewController(_ controller: LocationPickerViewController, didPickLocation location: Location)
}

class LocationPickerViewController: UITableViewController {
    
    
    var dataModel: DataModel!
    
    var locationID: Int?
    
    var location: Location?
    
    var editingLocations: Bool?
    
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
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
        delegate?.locationPickerViewControllerDidCancel(self)
        
    }
    
    func edit() {
        editButton.title = "Done"
        cancelButton.title = "Done"
        cancelButton.target = self
        cancelButton.action = #selector(LocationPickerViewController.done)
        cancelButton.style = .done
        tableView.isEditing = true
        editButton.style = UIBarButtonItemStyle.done
        
        editButton.action = #selector(LocationPickerViewController.done)
    }
    
    func done() {
        tableView.isEditing = false
        editButton.style = .plain
        editButton.title = "Delete"
        editButton.action = #selector(LocationPickerViewController.edit)
        cancelButton.title = "Cancel"
        if let editing = editingLocations {
            if editing {
                cancelButton.title = "< Back"
            }
        }
        
        cancelButton.action = #selector(LocationPickerViewController.cancel)
        cancelButton.style = .plain
        cancelButton.target = self
    }
    
        
    

    override func viewDidLoad() {
        super.viewDidLoad()
                self.navigationItem.rightBarButtonItem = editButton
        if let thisLocation = getLocation() {
            location = thisLocation
        }
        if dataModel == nil {
            print("DataModel not passed to locationPicker")
        }
        
        if let editing = editingLocations {
            if editing {
                editButton.target = self
                editButton.isEnabled = true
                editButton.title = "Delete"
                editButton.action = #selector(LocationPickerViewController.edit)
                cancelButton.title = "< Back"

            } else {
                editButton.title = ""
                editButton.isEnabled = false

            }
        }
  /*      let location0 = Location()
        location0.name = "Kroger"
        locations.append(location0)
        
        let location1 = Location()
        location1.name = "Meijer"
        locations.append(location1)
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    //    println("LocationPicker Locations: \(dataModel.locations)")
    }

    override func didReceiveMemoryWarning() {
    //    println("***DID RECEIVE MEMORY WARNING***")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let indexPath = sender as! IndexPath
            let editLocation = dataModel.locations[indexPath.row]
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailController
            controller.locationID = editLocation.myID
            controller.dataModel = dataModel
        } else if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
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
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
      //  println("Number of locations in data model: \(dataModel.locations.count)")
        return dataModel.locations.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < dataModel.locations.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) 
            cell.textLabel?.text = dataModel.locations[indexPath.row].name
            cell.accessoryType = .none
            if let thisLocation = location {
                if thisLocation.myID == dataModel.locations[indexPath.row].myID {
                    cell.accessoryType = .checkmark
                }
            }
            if let editing = editingLocations {
                if editing {
                    cell.accessoryType = .disclosureIndicator
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddLocationButtonCell", for: indexPath) 
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let editing = editingLocations {
            if editing {
                if indexPath.row < dataModel.locations.count {
                    performSegue(withIdentifier: "EditLocation", sender: indexPath)
                }
            }
        }
        if indexPath.row < dataModel.locations.count && delegate != nil {
            location = dataModel.locations[indexPath.row]
            delegate?.locationPickerViewController(self, didPickLocation: location!)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
 
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row < dataModel.locations.count {
            if tableView.isEditing {
                return UITableViewCellEditingStyle.delete
            }
        }
            return UITableViewCellEditingStyle.none
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let alertView = UIAlertController(title: "Are you sure?", message: "Deleting a Location also deletes all events at that location", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {
            _ in
            for list in self.dataModel.lists {
                                    
                  /*  if list.checklist[i].locationID == self.dataModel.locations[indexPath.row].myID {
                        list.checklist.removeAtIndex(i)
*/
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
        
    


    
}

extension LocationPickerViewController: MapViewControllerDelegate {
    func mapViewControllerDidExit(_ controller: MapViewController) {
        dismiss(animated: true, completion: nil)
        dataModel.locations = controller.locations
        dataModel.saveLocationItems()
        print("savedLocations")
    }
}



