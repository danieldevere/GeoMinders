//
//  TagLocationViewController.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/10/17.
//  Copyright (c) 2017 DANIEL DEVERE. All rights reserved.
//

import UIKit

protocol TagLocationViewControllerDelegate: class {
    func tagLocationViewControllerDidGoBack(_ controller: TagLocationViewController)
    func tagLocationViewController(_ controller: TagLocationViewController, didSaveTag tag: Location)
}

class TagLocationViewController: UITableViewController {
    
    // MARK: - Variables
    
    var delegate: TagLocationViewControllerDelegate?
    var taggedLocation: Location?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressName: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    
    // MARK: - Action Functions
    
    // User presses cancel button
    @IBAction func goBack(_ sender: AnyObject) {
        delegate?.tagLocationViewControllerDidGoBack(self)
    }
    // User presses Save button
    @IBAction func saveTag(_ sender: AnyObject) {
        // Set location name from field
        if let location = taggedLocation {
            if !(textField.text?.isEmpty)! {
                location.name = textField.text!
            }
            // Set the location id
            if UserDefaults.standard.object(forKey: "LocationIndex") != nil {
                let locationIndex = UserDefaults.standard.integer(forKey: "LocationIndex")
                location.myID = locationIndex
                UserDefaults.standard.set(locationIndex + 1, forKey: "LocationIndex")
            // First location added
            } else {
                print("did this run")
                location.myID = 0
                UserDefaults.standard.set(0, forKey: "LocationIndex")
            }
            delegate?.tagLocationViewController(self, didSaveTag: location)
        } else {
            print("Error: No location passed")
        }
    }
    
    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = taggedLocation?.name
        textField.becomeFirstResponder()
        addressLabel.text = taggedLocation?.address
        addressName.text = taggedLocation?.addressName
        if let radius = taggedLocation?.radius {
            radiusLabel.text = "\(Int((radius / 0.3048).rounded()))ft"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    // rows can't be selected
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
