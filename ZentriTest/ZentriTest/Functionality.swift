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
	
	func manageResponse(with json: String) -> Bool {
		
		switch self {
		case .block:
			if let _ = json.toObject(BapiResponse<String>.self) {
				print("block success")
				return true
			} else {
				return false
			}
		case .unblock:
			if let _ = json.toObject(BapiResponse<String>.self) {
				print("unblock success")
				return true
			} else {
				return false
			}
		case .readFirmwareVersion:
			if let object = json.toObject(BapiResponse<Int>.self) {
				print("firmware version is \(object.response ?? 0)")
				return true
			} else {
				return false
			}
		case .readSerialNumber:
			if let object = json.toObject(BapiResponse<Int>.self) {
				print(object)
				return true
			} else {
				//This is always nil because charger answers r: 0000XXX as an integer which is a corrupted integer,
				//so the toObject function does not recognize it as a correct data
				print("error reading serial number")
				return false
			}
		case .readState:
			if let object = json.toObject(BapiResponse<State>.self) {
				print(object.response ?? "no state")
				return true
			} else {
				return false
			}
		}
	}	
}

struct State: Codable {
	
	let L1: Int
	let L2: Int
	let L3: Int
	let st: Int
	let cur: Int
	let en: Int
	let s: Int
	let ps: Int
	let usid: Int
	
	enum CodingKeys: String, CodingKey {
		case L1
		case L2
		case L3
		case st
		case cur
		case en
		case s
		case ps
		case usid
	}
	
}
