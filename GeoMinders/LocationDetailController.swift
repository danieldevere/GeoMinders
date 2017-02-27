//
//  LocationDetailController.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/21/17.
//  Copyright © 2017 DANIEL DEVERE. All rights reserved.
//

import UIKit


class LocationDetailController: UITableViewController {
    
    // MARK: - Variables
    
    var locationID: Int?
    var dataModel: DataModel!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - Action Functions
    
    // User taps done after editing location only available if there is some text in the field
    @IBAction func done() {
        if !(textField.text?.isEmpty)! {
            let location = getLocation()
            location.name = textField.text!
            dataModel.saveLocationItems()
            dismiss(animated: true, completion: nil)
        }
        
    }

    @IBAction func textFieldEdit() {
        if (textField.text?.isEmpty)! {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
    // User taps cancel to throw out changes
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let location = getLocation()
        textField.text = location.name
        nameLabel.text = location.addressName
        addressLabel.text = location.address
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segue when user taps show map cell
        if segue.identifier == "ShowLocation" {
            let controller = segue.destination as! MapViewController
            controller.editingLocation = true
            controller.locations = [getLocation()]
        }
    }
    
    // MARK: - Functions
    
    // Get location from location ID
    func getLocation() -> Location {
        if let id = locationID {
            for location in dataModel.locations {
                if location.myID == id {
                    return location
                }
            }
        }
        return Location()
    }
}


