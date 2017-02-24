//
//  LocationDetailController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/21/17.
//  Copyright © 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit


class LocationDetailController: UITableViewController {
    
    var locationID: Int?
    
    var dataModel: DataModel!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBAction func done() {
        if !(textField.text?.isEmpty)! {
            let location = getLocation()
            location.name = textField.text!
            dataModel.saveLocationItems()
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldEdit() {
        if (textField.text?.isEmpty)! {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
    
    
    func getLocation() -> Location {
        if let id = locationID {
            for location in dataModel.locations {
                if location.myID == id {
                    return location
                }
                
            }
        }
        print("LocationDetailController can't find location")
        return Location()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let location = getLocation()
        textField.text = location.name
        nameLabel.text = location.addressName
       // addressLabel.text = "\(location.placemark?.subThoroughfare) \(location.placemark?.thoroughfare) \(location.placemark?.locality), \(location.placemark?.administrativeArea) \(location.placemark?.postalCode)"
        addressLabel.text = location.address
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! MapViewController
            controller.editingLocation = true
            controller.locations = [getLocation()]
        }
    }

    // MARK: - Table view data source
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


