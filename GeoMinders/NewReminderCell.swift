//
//  NewReminderCell.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/5/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit

protocol NewReminderCellDelegate: class {
    func newReminderCell(controller: NewReminderCell, didPressDoneAddingReminder reminder: ReminderItem)
    func newReminderCellDidCancelWithTap(controller: NewReminderCell)
}

class NewReminderCell: UITableViewCell {
    
    weak var delegate: NewReminderCellDelegate?

    @IBOutlet weak var textField: UITextField!

    @IBAction func done() {
        println("Text: \(textField.text)")
        textField.resignFirstResponder()
        let item = ReminderItem()
        item.reminderText = textField.text
        item.checked = false
        delegate?.newReminderCell(self, didPressDoneAddingReminder: item)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

