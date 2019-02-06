//
//  CommandParser.swift
//  ZentriTest
//
//  Created by Santi on 29/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation

class CommandParser {
	
	private var saveSent = false
	private var rebootSent = false
	
	func nextCommand(response: String, for command: Command) -> String? {
		
		if !command.needSave {
			return nil
		}
		
		if !saveSent {
			saveSent = true
			return "save"
		}
		
		if !rebootSent {
			rebootSent = true
			return "reboot"
		}
		
		saveSent = false
		rebootSent = false
		return nil
		
	}
	
}
