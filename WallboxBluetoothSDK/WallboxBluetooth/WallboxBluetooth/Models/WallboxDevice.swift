//
//  WallboxDevice.swift
//  WallboxBluetooth
//
//  Created by Michel on 05/02/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct WallboxDevice {
    public let identifier: String
    public let name: String?
    public var state: WallboxDeviceState = .disconnected
    
    var rxCharacteristic: CBCharacteristic?
    var txCharacteristic: CBCharacteristic?
    var modeCharacteristic: CBCharacteristic?
    
    public init(identifier: String, name: String?, state: WallboxDeviceState) {
        self.identifier = identifier
        self.name = name
        self.state = state
    }
}

public enum WallboxDeviceState {
    case disconnected
    case connecting
    case connected
    case disconnecting
}
