//
//  ReminderItemDetailViewController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/6/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit

protocol ReminderItemDetailViewControllerDelegate: class {
    func reminderItemDetailViewController(controller: ReminderItemDetailViewController, didFinishEditingReminder reminder: ReminderItem)
    func reminderItemDetailViewControllerDidCancel(controller: ReminderItemDetailViewController)
}

class ReminderItemDetailViewController: UITableViewController {
    
    var reminderItem: ReminderItem?
    
    var tempLocation: Location?
    
    weak var delegate: ReminderItemDetailViewControllerDelegate?
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var locationDetailLabel: UILabel!
    
    @IBOutlet weak var listLabel: UILabel!
    
    
    @IBAction func done() {
        if let delegate = delegate {
            reminderItem?.reminderText = textField.text
            reminderItem?.location = tempLocation
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
            locationLabel.text = item.location?.name
            locationDetailLabel.text = item.location?.subtitle
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    

    override func didReceiveMemoryWarning() {
    //    println("***DID RECEIVE MEMORY WARNING***")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationPickerViewController
            controller.delegate = self
            if let location = tempLocation {
                controller.location = tempLocation
            } else {
                controller.location = reminderItem?.location
            }
            
        }
    }
}
extension ReminderItemDetailViewController: LocationPickerViewControllerDelegate {
    func locationPickerViewController(controller: LocationPickerViewController, didPickLocation location: Location) {
        tempLocation = location
        locationLabel.text = tempLocation?.name
        locationDetailLabel.text = tempLocation?.subtitle
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationPickerViewControllerDidCancel(controller: LocationPickerViewController) {
     //   println("before dismiss")
  //      dismissViewControllerAnimated(true, completion: nil)
        controller.delegate = nil
    //    println("after dismiss")
    }
}
