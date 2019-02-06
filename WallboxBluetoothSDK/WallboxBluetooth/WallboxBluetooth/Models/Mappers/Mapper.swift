//
//  Mapper.swift
//  WallboxBluetooth
//
//  Created by Michel on 05/02/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation

protocol Mapper {
    associatedtype IN
    associatedtype OUT
    static func map(input: IN) -> OUT
}
