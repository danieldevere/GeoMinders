//
//  TagLocationViewController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/10/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit

protocol TagLocationViewControllerDelegate: class {
    func tagLocationViewControllerDidGoBack(_ controller: TagLocationViewController)
    func tagLocationViewController(_ controller: TagLocationViewController, didSaveTag tag: Location)
}

class TagLocationViewController: UITableViewController {
    
    var delegate: TagLocationViewControllerDelegate?
    
    var taggedLocation: Location?

    
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    
    @IBAction func goBack(_ sender: AnyObject) {
        delegate?.tagLocationViewControllerDidGoBack(self)
    }
    
    @IBAction func saveTag(_ sender: AnyObject) {
        if let location = taggedLocation {
            print("Location: \(location.name) id: \(location.myID)")
            if !(textField.text?.isEmpty)! {
                location.name = textField.text!
            }
            if UserDefaults.standard.object(forKey: "LocationIndex") != nil {
                let locationIndex = UserDefaults.standard.integer(forKey: "LocationIndex")
                location.myID = locationIndex + 1
                UserDefaults.standard.set(locationIndex + 1, forKey: "LocationIndex")
                
            } else {
                location.myID = 0
                UserDefaults.standard.set(0, forKey: "LocationIndex")
            }
            delegate?.tagLocationViewController(self, didSaveTag: location)
        } else {
            print("Error: No location passed")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.text = taggedLocation?.name
        textField.becomeFirstResponder()
        addressLabel.text = taggedLocation?.subtitle

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    

    // MARK: - Table view data source

   
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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
