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
    @IBOutlet weak var reminderNameLabel: UILabel!
    @IBOutlet weak var reminderDetailLabel: UILabel!
    @IBOutlet weak var reminderCheckbox: UIImageView!
    
    

    @IBAction func detailButton(sender: AnyObject) {
        performSegueWithIdentifier("ShowDetail", sender: sender)
    }
    
    required init(coder aDecoder: NSCoder) {
        checklist = [ReminderItem]()
        super.init(coder: aDecoder)
        loadReminderItems()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var cellNib = UINib(nibName: "NewReminderCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "NewReminderCell")
    //    cellNib = UINib(nibName: "ReminderItemCell", bundle: nil)
    //    tableView.registerNib(cellNib, forCellReuseIdentifier: "ReminderItemCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
                controller.reminderItem = checklist[indexPath.row]
                controller.delegate = self
            }
        }
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
            let cell = tableView.dequeueReusableCellWithIdentifier("ReminderItemCell", forIndexPath: indexPath) as! UITableViewCell
            let reminderText = cell.viewWithTag(1001) as! UILabel
            let reminderDetailText = cell.viewWithTag(1002) as! UILabel
            reminderText.text = item.reminderText
            reminderDetailText.text = item.detailText
            updateCheckmarkForCell(cell, withReminderItem: checklist[indexPath.row])
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
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            saveReminderItems()
            tableView.reloadData()
        }
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
        println("Directory: \(paths[0])")
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return documentsDirectory().stringByAppendingPathComponent("GeoMinders.plist")
    }
    
    func saveReminderItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(checklist, forKey: "Checklist")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadReminderItems() {
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                checklist = unarchiver.decodeObjectForKey("Checklist") as! [ReminderItem]
                unarchiver.finishDecoding()
            }
        }
    }
    
    func updateCheckmarkForCell(cell: UITableViewCell, withReminderItem reminder: ReminderItem) {
        let checkmark = cell.viewWithTag(1000) as! UIImageView
        if reminder.checked {
            checkmark.image = UIImage(named: "checkmark-512")
        } else {
            checkmark.image = UIImage()
        }
        
        
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
        controller.textField.text = ""
        saveReminderItems()
    }
    
    func newReminderCellDidCancelWithTap(controller: NewReminderCell) {
        
    }
}

extension RemindersViewController: ReminderItemDetailViewControllerDelegate {
    func reminderItemDetailViewController(controller: ReminderItemDetailViewController, didFinishEditingReminder reminder: ReminderItem) {
        dismissViewControllerAnimated(true, completion: nil)
        tableView.reloadData()
    }
    
    func reminderItemDetailViewControllerDidCancel(controller: ReminderItemDetailViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


