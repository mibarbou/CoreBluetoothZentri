//
//  Bapi.swift
//  ZentriTest
//
//  Created by Santi on 25/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation


struct Bapi<Paramenter: Codable>: Codable {
	
	let met: String
	let par: Paramenter?
	let id: Int
	
	init(met: String, par: Paramenter?, id: Int) {
		self.met = met
		self.par = par
		self.id = id
	}
	
	enum CodingKeys: String, CodingKey {
		case met
		case par
		case id
	}
}
