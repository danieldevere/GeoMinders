//
//  NewReminderCell.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/5/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit

protocol NewReminderCellDelegate: class {
    func newReminderCell(_ controller: NewReminderCell, didPressDoneAddingReminder reminder: ReminderItem)
    func newReminderCellDidCancelWithTap(_ controller: NewReminderCell)
}

class NewReminderCell: UITableViewCell {
    
    weak var delegate: NewReminderCellDelegate?

    @IBOutlet weak var textField: UITextField!

    @IBAction func done() {
     //   println("Text: \(textField.text)")
        textField.resignFirstResponder()
        let item = ReminderItem()
        item.reminderText = textField.text!
        item.checked = false
        if UserDefaults.standard.object(forKey: "ReminderIndex") != nil {
            let reminderIndex = UserDefaults.standard.integer(forKey: "ReminderIndex")
            item.myID = reminderIndex + 1
            UserDefaults.standard.set(reminderIndex + 1, forKey: "ReminderIndex")
        } else {
            item.myID = 0
            UserDefaults.standard.set(0, forKey: "ReminderIndex")
        }
        delegate?.newReminderCell(self, didPressDoneAddingReminder: item)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

