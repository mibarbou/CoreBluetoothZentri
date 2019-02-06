//
//  CBPeripheralToWallboxDevice.swift
//  WallboxBluetooth
//
//  Created by Michel on 05/02/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation
import CoreBluetooth

struct CBPeripheralToWallboxDevice: Mapper {
    typealias IN = CBPeripheral
    typealias OUT = WallboxDevice
    
    static func map(input: CBPeripheral) -> WallboxDevice {
        
        return WallboxDevice(identifier: input.identifier.uuidString,
                             name: input.name,
                             state: wallboxDeviceStateFor(peripheral: input))
    }
    
    fileprivate static func wallboxDeviceStateFor(peripheral: CBPeripheral) -> WallboxDeviceState {
        switch peripheral.state {
        case .connected:
            return .connected
        case .connecting:
            return .connecting
        case .disconnected:
            return .disconnected
        case .disconnecting:
            return .disconnecting
        }
    }
}
