//
//  ReminderItemCell.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/5/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit

class ReminderItemCell: UITableViewCell {
    
    var reminderItem: ReminderItem?
    
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var checkmark: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
