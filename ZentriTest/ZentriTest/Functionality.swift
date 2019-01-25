//
//  Functionality.swift
//  ZentriTest
//
//  Created by Santi on 25/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation

enum Functionality: CaseIterable {
	
	typealias BapiJSON = String
	
	case block
	case unblock
	case readFirmwareVersion
	case readSerialNumber
	case readState
	
	var name: String {
		switch self {
		case .block:
			return "Bloquear"
		case .unblock:
			return "Desbloquear"
		case .readFirmwareVersion:
			return "Leer version firmware"
		case .readSerialNumber:
			return "Leer serial numbers"
		case .readState:
			return "Leer estado"
		}
	}
	
	func createBapi(id: Int) -> BapiJSON?  {
		switch self {
		case .block:
			return Bapi<Int>(met: "w_lck", par: 1, id: id).toJsonString()
		case .unblock:
			return Bapi<Int>(met: "w_lck", par: 0, id: id).toJsonString()
		case .readFirmwareVersion:
			return Bapi<String>(met: "fw_v_", par: "null", id: id).toJsonString()
		case .readSerialNumber:
			return Bapi<String>(met: "r_sn_", par: "null", id: id).toJsonString()
		case .readState:
			return Bapi<String>(met: "r_dat", par: "null", id: id).toJsonString()
		}
	}
}
