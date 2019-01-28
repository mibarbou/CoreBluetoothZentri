//
//  ResponseParser.swift
//  ZentriTest
//
//  Created by Santi on 28/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation


class ResponseParser {
	
	typealias ResponseJSON = String
	
	private var lastResponse = ""
	private var openersCount = 0
	private var closersCount = 0
	
	func parse(response: String) -> ResponseJSON? {
		
		lastResponse = lastResponse + response
		openersCount = openersCount + response.countOf(character: "{")
		closersCount = closersCount + response.countOf(character: "}")
		
		if openersCount != closersCount {
			return nil
		}
		
		let responseJSON = lastResponse
		reset()
		return responseJSON
	}
	
	fileprivate func reset() {
		openersCount = 0
		closersCount = 0
		lastResponse = ""
	}
	
}


