//
//  ReminderItemDetailViewController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/6/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit

protocol ReminderItemDetailViewControllerDelegate: class {
    func reminderItemDetailViewController(_ controller: ReminderItemDetailViewController, didFinishEditingReminder reminder: ReminderItem)
    func reminderItemDetailViewControllerDidCancel(_ controller: ReminderItemDetailViewController)
}

class ReminderItemDetailViewController: UITableViewController {
    
    var reminderItem: ReminderItem?
    
    var tempLocation: Location?
    
    var dataModel: DataModel!
    
    weak var delegate: ReminderItemDetailViewControllerDelegate?
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var locationDetailLabel: UILabel!
    
    
    
    @IBAction func done() {
        if let delegate = delegate {
            reminderItem?.reminderText = textField.text!
            if let newLocation = tempLocation {
                if reminderItem?.locationID != newLocation.myID {
                    for location in dataModel.locations {
                        if location.myID == reminderItem?.locationID {
                            location.remindersCount = location.remindersCount - 1
                            break
                        }
                    }
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
    
    @IBAction func cancel() {
        delegate?.reminderItemDetailViewControllerDidCancel(self)
    }
    
    
    override func viewDidLoad() {
     //   println("loaded")
        super.viewDidLoad()
        if let item = reminderItem {
            textField.text = item.reminderText
            locationLabel.text = item.detailText
            locationDetailLabel.text = item.locationAddress
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReminderItemDetailViewController.dismissKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    

    override func didReceiveMemoryWarning() {
    //    println("***DID RECEIVE MEMORY WARNING***")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    func dismissKeyboard() {
        textField.resignFirstResponder()
    }
}
extension ReminderItemDetailViewController: LocationPickerViewControllerDelegate {
    func locationPickerViewController(_ controller: LocationPickerViewController, didPickLocation location: Location) {
        tempLocation = location
        locationLabel.text = tempLocation?.name
        locationDetailLabel.text = tempLocation?.subtitle
        dismiss(animated: true, completion: nil)
    }
    
    func locationPickerViewControllerDidCancel(_ controller: LocationPickerViewController) {
     //   println("before dismiss")
  //      dismissViewControllerAnimated(true, completion: nil)
        controller.delegate = nil
    //    println("after dismiss")
    }
}
extension ReminderItemDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
