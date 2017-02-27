//
//  SettingsViewController.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/20/17.
//  Copyright © 2017 DANIEL DEVERE. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    // MARK: - Variables
    
    var dataModel: DataModel!
    
    @IBOutlet weak var alertSoundsToggle: UISwitch!
    @IBOutlet weak var additionalReminderToggle: UISwitch!
    @IBOutlet weak var deleteItemsToggle: UISwitch!
    
    // MARK: - Action Functions
    
    @IBAction func alertSoundsToggleSwitched() {
        if alertSoundsToggle.isOn {
            dataModel.settings.playAlertSounds = true
        } else {
            dataModel.settings.playAlertSounds = false
        }
        dataModel.saveSettings()
    }
    
    @IBAction func additionalReminderToggleSwitched() {
        if additionalReminderToggle.isOn {
            dataModel.settings.remindAgain = true
        } else {
            dataModel.settings.remindAgain = false
        }
        dataModel.saveSettings()
    }
    
    @IBAction func deleteItemToggleSwitched() {
        if deleteItemsToggle.isOn {
            dataModel.settings.deleteAfter30Days = true
        } else {
            dataModel.settings.deleteAfter30Days = false
        }
        dataModel.saveSettings()
    }
    // User taps close button
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertSoundsToggle.isOn = dataModel.settings.playAlertSounds
        additionalReminderToggle.isOn = dataModel.settings.remindAgain
        deleteItemsToggle.isOn = dataModel.settings.deleteAfter30Days
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segue when user taps edit locations cell
        if segue.identifier == "ShowLocations" {
            let controller = segue.destination as! LocationPickerViewController
            controller.dataModel = dataModel
            controller.editingLocations = true
        }
    }
    // Only allows taps of top row
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return indexPath
        }
        return nil
    }
}
