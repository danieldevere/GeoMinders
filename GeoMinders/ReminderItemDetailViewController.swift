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
    

    
    weak var delegate: ReminderItemDetailViewControllerDelegate?
    
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func done() {
        if let delegate = delegate {
            reminderItem?.reminderText = textField.text
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
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let indexPath = NSIndexPath(forRow: 0, inSection: 2)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.detailTextLabel?.text = reminderItem?.location?.name
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
            controller.reminderItem = reminderItem



            
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
   //     println("cellForRowAtIndexPath")
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   //    println("numberOfRowsInSection")
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
   //     println("numberOfSectionsInTableView")
        return 4
    }

}

extension ReminderItemDetailViewController: LocationPickerViewControllerDelegate {
    func locationPickerViewController(controller: LocationPickerViewController, didPickLocationForReminder reminder: ReminderItem) {
        reminderItem?.location = reminder.location
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationPickerViewControllerDidCancel(controller: LocationPickerViewController) {
     //   println("before dismiss")
        dismissViewControllerAnimated(true, completion: nil)
        controller.delegate = nil
    //    println("after dismiss")
    }
}
