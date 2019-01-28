//
//  BapiResponse.swift
//  ZentriTest
//
//  Created by Santi on 28/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation

struct BapiResponse<Response: Codable>: Codable {
	let response: Response?
	let id: Int
	
	enum CodingKeys: String, CodingKey {
		case response = "r"
		case id
	}
}
