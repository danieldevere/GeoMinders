//
//  AllListsViewController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/11/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController {
    
    var lists: [ReminderList]
    
    var addingList = false
    
    var atStore = false
    
    @IBOutlet weak var locationButton: UIBarButtonItem!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    @IBAction func addList() {
        addingList = true
        locationButton.title = "Cancel"
        locationButton.target = self
        locationButton.action = Selector("cancelNewList")
        addButton.enabled = false
        let indexPath = NSIndexPath(forRow: lists.count, inSection: 0)
        let indexPaths = [indexPath]
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        let textField = tableView.viewWithTag(3000) as! UITextField
        textField.becomeFirstResponder()
    }
    
    @IBAction func done() {
        let textField = tableView.viewWithTag(3000) as! UITextField
        let newList = ReminderList(name: textField.text)
        lists.append(newList)
        saveReminderItems()
        cancelNewList()
    }
    
    func cancelNewList() {
        addingList = false
        locationButton.title = "Locations"
        locationButton.target = self
        locationButton.action = Selector("locationButtonAction")
        addButton.enabled = true
        tableView.reloadData()
    }
    
    func locationButtonAction() {
        performSegueWithIdentifier("ShowLocations", sender: nil)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        lists = [ReminderList]()
        super.init(coder: aDecoder)
        loadReminderItems()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        if segue.identifier == "ShowChecklist" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! RemindersViewController
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            controller.reminderList = lists[indexPath!.row]
            controller.delegate = self
            println("Sender: \(sender)")
        }
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return numberOfRows()
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < lists.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("ListCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = lists[indexPath.row].name
            return cell
        } else if (atStore) && (indexPath.row == lists.count) {
            let cell = tableView.dequeueReusableCellWithIdentifier("ItemsToDoAtLocationCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = "Items to Buy Here"
            return cell
        } else if (addingList) && (indexPath.row >= lists.count) {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewListCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Deleting List", message: "This will delete all the items in the list", preferredStyle: UIAlertControllerStyle.Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {
            _ in
            self.lists.removeAtIndex(indexPath.row)
            let indexPaths = [indexPath]
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            self.saveReminderItems()
        })
        alert.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
        println("Directory: \(paths[0])")
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return documentsDirectory().stringByAppendingPathComponent("GeoMindersItems.plist")
    }
    
    func saveReminderItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(lists, forKey: "Checklists")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadReminderItems() {
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                if let checklists = unarchiver.decodeObjectForKey("Checklists") as? [ReminderList] {
                    lists = checklists
                }
                unarchiver.finishDecoding()
            }
        }
    }
    
    func numberOfRows() -> Int {
        var number = lists.count
        if addingList {
            number += 1
        }
        
        if atStore {
            number += 1
        }
        return number
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

extension AllListsViewController: RemindersViewControllerDelegate {
    func remindersViewControllerWantsToSave(controller: RemindersViewController) {
        saveReminderItems()
    }
}