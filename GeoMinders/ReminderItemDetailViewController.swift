//
//  ReminderItemDetailViewController.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/6/17.
//  Copyright (c) 2017 DANIEL DEVERE. All rights reserved.
//

import UIKit

protocol ReminderItemDetailViewControllerDelegate: class {
    func reminderItemDetailViewController(_ controller: ReminderItemDetailViewController, didFinishEditingReminder reminder: ReminderItem)
    func reminderItemDetailViewControllerDidCancel(_ controller: ReminderItemDetailViewController)
}

class ReminderItemDetailViewController: UITableViewController {
    
    // MARK: - Variables
    
    var reminderItem: ReminderItem?
    var tempLocation: Location?
    var dataModel: DataModel!
    weak var delegate: ReminderItemDetailViewControllerDelegate?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationDetailLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - Action functions
    
    // User finished editing reminder
    @IBAction func done() {
        if let delegate = delegate {
            reminderItem?.reminderText = textField.text!
            if let newLocation = tempLocation {
                // Update old location reminder count
                if reminderItem?.locationID != newLocation.myID {
                    for location in dataModel.locations {
                        if location.myID == reminderItem?.locationID {
                            location.remindersCount = location.remindersCount - 1
                            break
                        }
                    }
                    // Update new location reminder count
                    reminderItem?.locationID = newLocation.myID
                    newLocation.remindersCount = newLocation.remindersCount + 1
                    reminderItem?.detailText = newLocation.name
                    reminderItem?.locationAddress = newLocation.subtitle!
                }
            }
            textField.resignFirstResponder()
            delegate.reminderItemDetailViewController(self, didFinishEditingReminder: reminderItem!)
        }
    }
    // User hits cancel which throws out any changes
    @IBAction func cancel() {
        delegate?.reminderItemDetailViewControllerDidCancel(self)
    }
    // Disables the save button if no text
    @IBAction func textFieldEdit() {
        if textField.text!.isEmpty {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = reminderItem {
            textField.text = item.reminderText
            locationLabel.text = item.detailText
            locationDetailLabel.text = item.locationAddress
        }
        // Dismiss keyboard if the user taps anywhere other than keyboard or text field
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReminderItemDetailViewController.dismissKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Open location picker to pick new location
        if segue.identifier == "PickLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationPickerViewController
            controller.delegate = self
            controller.dataModel = dataModel
            controller.editingLocations = false
            if let location = tempLocation {
                controller.locationID = location.myID
            } else {
                controller.locationID = reminderItem?.locationID
            }
        }
    }
    
    // MARK: - Functions
    
    func dismissKeyboard() {
        textField.resignFirstResponder()
    }
}

// MARK: - Location Picker delegate

extension ReminderItemDetailViewController: LocationPickerViewControllerDelegate {
    func locationPickerViewController(_ controller: LocationPickerViewController, didPickLocation location: Location) {
        tempLocation = location
        locationLabel.text = tempLocation?.name
        locationDetailLabel.text = tempLocation?.subtitle
        dismiss(animated: true, completion: nil)
    }
    
    func locationPickerViewControllerDidCancel(_ controller: LocationPickerViewController) {
    }
}

// MARK: - Gesture Recognizer delegate

extension ReminderItemDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
