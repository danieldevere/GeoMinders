//
//  RemindersViewController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/5/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit

class RemindersViewController: UITableViewController {

    var checklist = [ReminderItem]()
    
    

    @IBAction func detailButton(sender: AnyObject) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var cellNib = UINib(nibName: "NewReminderCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "NewReminderCell")
        cellNib = UINib(nibName: "ReminderItemCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ReminderItemCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return checklist.count + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < checklist.count {
            let item = checklist[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("ReminderItemCell", forIndexPath: indexPath) as! ReminderItemCell
                cell.reminderLabel.text = item.reminderText
                cell.detailLabel.text = item.detailText
                if item.checked {
                    cell.checkmark.image = UIImage(named: "checkmark-512")
                } else {
                    cell.checkmark.image = UIImage()
                }
                
            

            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewReminderCell", forIndexPath: indexPath) as! NewReminderCell
            cell.delegate = self
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < checklist.count {
            checklist[indexPath.row].checked = !checklist[indexPath.row].checked
            tableView.reloadData()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    func configureCells() {
        let item0 = ReminderItem()
        item0.checked = false
        item0.reminderText = "Something"
        item0.detailText = ""
        checklist.append(item0)
        
        let item1 = ReminderItem()
        item1.checked = false
        item1.reminderText = "Something else"
        item1.detailText = "test"
        checklist.append(item1)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

extension RemindersViewController: NewReminderCellDelegate {
    func newReminderCell(controller: NewReminderCell, didPressDoneAddingReminder reminder: ReminderItem) {
        checklist.append(reminder)
        let indexPath = NSIndexPath(forRow: checklist.count - 1, inSection: 0)
        let indexPaths = [indexPath]
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    
    func newReminderCellDidCancelWithTap(controller: NewReminderCell) {
        
    }
}


