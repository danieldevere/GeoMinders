//
//  Settings.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/20/17.
//  Copyright © 2017 DANIEL DE VERE. All rights reserved.
//

import Foundation

class Settings: NSObject, NSCoding {
    var remindAgain: Bool
    var playAlertSounds: Bool
    var deleteAfter30Days: Bool
    
    init(remindAgain: Bool, playAlertSounds: Bool, deleteAfter30Days: Bool) {
        self.remindAgain = remindAgain
        self.playAlertSounds = playAlertSounds
        self.deleteAfter30Days = deleteAfter30Days
    }
    
    required init(coder aDecoder: NSCoder) {
        remindAgain = aDecoder.decodeBool(forKey: "RemindAgain")
        playAlertSounds = aDecoder.decodeBool(forKey: "PlayAlertSounds")
        deleteAfter30Days = aDecoder.decodeBool(forKey: "DeleteAfter30Days")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(remindAgain, forKey: "RemindAgain")
        aCoder.encode(playAlertSounds, forKey: "PlayAlertSounds")
        aCoder.encode(deleteAfter30Days, forKey: "DeleteAfter30Days")
    }
}
