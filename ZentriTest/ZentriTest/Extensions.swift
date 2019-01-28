//
//  Extensions.swift
//  ZentriTest
//
//  Created by Santi on 25/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation

extension Encodable {
	
	func toJsonString() -> String? {
		
		let jsonEncoder = JSONEncoder()
		do {
			let jsonData = try jsonEncoder.encode(self)
			let jsonString = String(data: jsonData, encoding: .utf8)
			return jsonString
		}
		catch {
			return nil
		}
	}
	
}

extension String {
	
	func toObject<T : Decodable>(_ type : T.Type) -> T? {
		
		guard let data = self.data(using: .utf8) else {
			return nil
		}
		
		let jsonDecoder = JSONDecoder()
		
		do {
			let object = try jsonDecoder.decode(T.self, from: data)
			return object
		}
		catch {
			return nil
		}
		
	}
	
	func countOf(character: Character) -> Int {
		var count = 0
		
		self.forEach {
			if $0 == character {
				count = count + 1
			}
		}
		
		return count
	}
}
