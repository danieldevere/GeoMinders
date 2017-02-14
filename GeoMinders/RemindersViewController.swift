//
//  RemindersViewController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/5/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit
import CoreData

protocol RemindersViewControllerDelegate: class {
    func remindersViewControllerWantsToSave(controller: RemindersViewController)
}

class RemindersViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!

    var reminderList: ReminderList
    
    var tempReminder = ReminderItem()
    
    var delegate: RemindersViewControllerDelegate?
    
    @IBOutlet weak var reminderNameLabel: UILabel!
    @IBOutlet weak var reminderDetailLabel: UILabel!
    @IBOutlet weak var reminderCheckbox: UIImageView!
    
    

    @IBAction func detailButton(sender: AnyObject) {
        performSegueWithIdentifier("ShowDetail", sender: sender)
    }
  
    required init(coder aDecoder: NSCoder) {
        reminderList = ReminderList()
        super.init(coder: aDecoder)
 //       loadReminderItems()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var cellNib = UINib(nibName: "NewReminderCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "NewReminderCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ReminderItemDetailViewController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                controller.reminderItem = reminderList.checklist[indexPath.row]
                controller.delegate = self
            }
        } else if segue.identifier == "PickLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationPickerViewController
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            println("Pick Location Segue")
        }
        
    }
    

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("Number of row: \(reminderList.checklist.count)")
        return reminderList.checklist.count + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < reminderList.checklist.count {
            let item = reminderList.checklist[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("ReminderItemCell", forIndexPath: indexPath) as! UITableViewCell
            let reminderText = cell.viewWithTag(1001) as! UILabel
            let reminderDetailText = cell.viewWithTag(1002) as! UILabel
            reminderText.text = item.reminderText
            reminderDetailText.text = item.location?.name
            cell.accessoryType = UITableViewCellAccessoryType.DetailButton
            updateCheckmarkForCell(cell, withReminderItem: reminderList.checklist[indexPath.row])
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewReminderCell", forIndexPath: indexPath) as! NewReminderCell
            cell.delegate = self
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < reminderList.checklist.count {
            reminderList.checklist[indexPath.row].checked = !reminderList.checklist[indexPath.row].checked
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
    //        delegate?.remindersViewControllerWantsToSave(self)
    //        saveReminderItems()
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        reminderList.checklist.removeAtIndex(indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    //    delegate?.remindersViewControllerWantsToSave(self)
    //    saveReminderItems()
    }
    
  /*
        */
    func updateCheckmarkForCell(cell: UITableViewCell, withReminderItem reminder: ReminderItem) {
        let checkmark = cell.viewWithTag(1000) as! UIImageView
        if reminder.checked {
            checkmark.image = UIImage(named: "checkmark-512")
        } else {
            checkmark.image = UIImage()
        }
        
        
    }
    
}



extension RemindersViewController: NewReminderCellDelegate {
    func newReminderCell(controller: NewReminderCell, didPressDoneAddingReminder reminder: ReminderItem) {
        println("pressedDone")
        tempReminder = reminder
                controller.textField.text = ""
        
        performSegueWithIdentifier("PickLocation", sender: nil)
    }
    
    func newReminderCellDidCancelWithTap(controller: NewReminderCell) {
        
    }
}

extension RemindersViewController: ReminderItemDetailViewControllerDelegate {
    func reminderItemDetailViewController(controller: ReminderItemDetailViewController, didFinishEditingReminder reminder: ReminderItem) {
        dismissViewControllerAnimated(true, completion: nil)
        tableView.reloadData()
  //      saveReminderItems()
    }
    
    func reminderItemDetailViewControllerDidCancel(controller: ReminderItemDetailViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension RemindersViewController: LocationPickerViewControllerDelegate {
    func locationPickerViewController(controller: LocationPickerViewController, didPickLocation location: Location) {
        tempReminder.location = location
        reminderList.checklist.append(tempReminder)
        dismissViewControllerAnimated(true, completion: nil)
        let indexPath = NSIndexPath(forRow: reminderList.checklist.count - 1, inSection: 0)
        let indexPaths = [indexPath]
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)


        tableView.reloadData()
    //    delegate?.remindersViewControllerWantsToSave(self)
 //       saveReminderItems()
    }
    
    func locationPickerViewControllerDidCancel(controller: LocationPickerViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


