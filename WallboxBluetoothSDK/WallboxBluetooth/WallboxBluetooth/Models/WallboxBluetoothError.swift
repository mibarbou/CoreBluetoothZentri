//
//  WallboxBluetoothError.swift
//  WallboxBluetooth
//
//  Created by Michel on 04/02/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation

public enum WallboxBluetoothError: Error {
    case deviceFailedToConnect
    case bluetoothUnavailable
    case deviceNotFound
    case unknown
}
