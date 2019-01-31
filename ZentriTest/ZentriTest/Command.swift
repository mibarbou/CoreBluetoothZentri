//
//  Command.swift
//  ZentriTest
//
//  Created by Santi on 29/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation

enum Command: CaseIterable {
	case getAllData
	case changeName
	case updateFirmware
	
	var name: String {
		switch self {
		case .getAllData:
			return "Retrive all BLE data"
		case .changeName:
			return "Change BLE name"
		case .updateFirmware:
			return "Update firmware (just for pulsar!!)"
		}
	}
	
	var command: String {
		switch self {
		case .getAllData:
			return "get al"
		case .changeName:
			return "set sy d n WB001134"
		case .updateFirmware:
			return "FIRMWARE"
		}
	}
	
	var needSave: Bool {
		switch self {
		case .getAllData:
			return false
		case .changeName:
			return true
		case .updateFirmware:
			return false
		}
	}
}
