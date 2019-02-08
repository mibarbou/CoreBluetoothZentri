//
//  WallboxBluetooth.swift
//  WallboxBluetooth
//
//  Created by Michel on 04/02/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol WallboxBluetoothDelegate: class {
    func bluetoothDidUpdateState(_ isOn: Bool)
}

open class WallboxBluetooth: NSObject {
    fileprivate let serviceTruconnectUUID = CBUUID(string: "175f8f23-a570-49bd-9627-815a6a27de2a")
    fileprivate let characteristicTruconnectPeripheralRXUUID = CBUUID(string: "1cce1ea8-bd34-4813-a00a-c76e028fadcb")
    fileprivate let characteristicTruconnectPeripheralTXUUID = CBUUID(string: "cacc07ff-ffff-4c48-8fae-a9ef71b75e26")
    fileprivate let characteristicTruconnectModeUUID = CBUUID(string: "20b9794f-da1a-4d14-8014-a0fb9cefb2f7")
    
    public weak var delegate: WallboxBluetoothDelegate?
    
    public var isConnected: Bool = false
    
    public var currentMode: ZentriMode = .remote
    
    fileprivate var centralManager: CBCentralManager!
    fileprivate var peripherals: [CBPeripheral] = []
    fileprivate var peripheral :CBPeripheral?
    fileprivate var isBluetoothAvailable = false
    
    fileprivate var currentConnectedDevice: WallboxDevice?
    fileprivate var rxCharacteristic: CBCharacteristic?
    fileprivate var txCharacteristic: CBCharacteristic?
    fileprivate var modeCharacteristic: CBCharacteristic?
    
    fileprivate var deviceFoundClosure: ((WallboxDevice) -> ())?
    fileprivate var bluetoothStateClosure: ((Bool) -> ())?
    fileprivate var deviceConnectedClosure: ((WallboxDevice) -> ())?
    fileprivate var connectFailureClosure: ((WallboxBluetoothError) -> ())?
    fileprivate var deviceDisconnectedClosure: ((WallboxDevice) -> ())?

    public override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
}

//MARK: - Public Methods

extension WallboxBluetooth {
    
    public func startScan(deviceFound: @escaping (WallboxDevice) -> (), error: @escaping (WallboxBluetoothError) -> ()) {
        deviceFoundClosure = deviceFound
        initScan { (state) in
            if state {
                self.peripherals.removeAll()
                self.centralManager.scanForPeripherals(withServices: [self.serviceTruconnectUUID])
                return
            }
            error(.bluetoothUnavailable)
        }
    }
    
    public func stopScan() {
        self.centralManager.stopScan()
    }
    
    public func connect(device: WallboxDevice,
                        success: @escaping (WallboxDevice) -> (),
                        failure: @escaping (WallboxBluetoothError) -> ()) {
        deviceConnectedClosure = success
        connectFailureClosure = failure
        do {
            let peripheral = try getPeripheralWith(identifier: device.identifier)
            self.centralManager.connect(peripheral, options: nil)
        } catch WallboxBluetoothError.deviceNotFound {
            failure(.deviceNotFound)
        } catch {
            failure(.unknown)
        }
    }
    
    public func disconnect(device: WallboxDevice,
                           success: @escaping (WallboxDevice) -> (),
                           failure: @escaping (WallboxBluetoothError) -> ()) {
        deviceDisconnectedClosure = success
        do {
            let peripheral = try getPeripheralWith(identifier: device.identifier)
            self.centralManager.cancelPeripheralConnection(peripheral)
        } catch WallboxBluetoothError.deviceNotFound {
            failure(.deviceNotFound)
        } catch {
            failure(.unknown)
        }
    }
    
    public func send(command: String) {
        
    }
    
    public func send(command: String, success: @escaping () -> (), failure: @escaping (WallboxBluetoothError) -> ()) {
        
    }
    
    public func setMode(_ mode: ZentriMode) {
        
    }
}


//MARK: - Private Methods

extension WallboxBluetooth {
    
    fileprivate func initScan(bluetoothState: @escaping (Bool) -> ()) {
        bluetoothStateClosure = bluetoothState
    }
    
    fileprivate func getPeripheralWith(identifier: String) throws -> CBPeripheral {
        if self.peripherals.count == 0 {
            throw WallboxBluetoothError.deviceNotFound
        }
        let peripherals = self.peripherals.filter { $0.identifier.uuidString.lowercased() == identifier.lowercased() }
        guard let peripheralFound = peripherals.first else {
            throw WallboxBluetoothError.deviceNotFound
        }
        return peripheralFound
    }
    
    fileprivate func isPeripheralAppended(_ peripheral: CBPeripheral) -> Bool {
        let peripherals = self.peripherals.filter { $0.identifier.uuidString.lowercased() == peripheral.identifier.uuidString.lowercased() }
        if let _ = peripherals.first {
            return true
        }
        return false
    }
    
    fileprivate func subscribeTo(characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case characteristicTruconnectPeripheralRXUUID:
            rxCharacteristic = characteristic
        case characteristicTruconnectPeripheralTXUUID:
            txCharacteristic = characteristic
            self.peripheral?.setNotifyValue(true, for: txCharacteristic!)
        case characteristicTruconnectModeUUID:
            modeCharacteristic = characteristic
            self.peripheral?.setNotifyValue(true, for: modeCharacteristic!)
            break
        default:
            break
        }
        
        if let rxChar = rxCharacteristic,
            let txChar = txCharacteristic,
            let modeChar = modeCharacteristic,
            var device = currentConnectedDevice,
            let closure = deviceConnectedClosure {
                device.rxCharacteristic = rxChar
                device.txCharacteristic = txChar
                device.modeCharacteristic = modeChar
                closure(device)
                rxCharacteristic = nil
                txCharacteristic = nil
                modeCharacteristic = nil
        }
    }
}

//MARK: - CBCentralManagerDelegate

extension WallboxBluetooth: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
            self.isBluetoothAvailable = false
            delegate?.bluetoothDidUpdateState(false)
        case .resetting:
            print("central.state is .resetting")
            self.isBluetoothAvailable = false
            delegate?.bluetoothDidUpdateState(false)
        case .unsupported:
            print("central.state is .unsupported")
            self.isBluetoothAvailable = false
            delegate?.bluetoothDidUpdateState(false)
        case .unauthorized:
            print("central.state is .unauthorized")
            self.isBluetoothAvailable = false
            delegate?.bluetoothDidUpdateState(false)
        case .poweredOff:
            print("central.state is .poweredOff")
            self.isBluetoothAvailable = false
            delegate?.bluetoothDidUpdateState(false)
        case .poweredOn:
            print("central.state is .poweredOn")
//            self.isBluetoothAvailable = true
//            delegate?.bluetoothDidUpdateState(true)
            if let closure = bluetoothStateClosure {
                closure(true)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {

//        print("peripheral found: \(peripheral.name ?? "")")
        if !isPeripheralAppended(peripheral) {
            self.peripherals.append(peripheral)
            let device = CBPeripheralToWallboxDevice.map(input: peripheral)
            if let closure = deviceFoundClosure {
                closure(device)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let device = CBPeripheralToWallboxDevice.map(input: peripheral)
        self.currentConnectedDevice = device
        print("WallboxBluetooth device connected: \(device.name ?? "unknown")")
        peripheral.delegate = self
        peripheral.discoverServices([serviceTruconnectUUID])
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        if let closure = connectFailureClosure {
            closure(.deviceFailedToConnect)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let closure = deviceDisconnectedClosure {
            let device = CBPeripheralToWallboxDevice.map(input: peripheral)
            self.currentConnectedDevice = nil
            print("WallboxBluetooth device disconnected: \(device.name ?? "unknown")")
            closure(device)
        }
    }
}

//MARK: - CBPeripheralDelegate

extension WallboxBluetooth: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first else { return }
        peripheral.discoverCharacteristics([characteristicTruconnectPeripheralRXUUID,
                                            characteristicTruconnectPeripheralTXUUID,
                                            characteristicTruconnectModeUUID],
                                           for: service)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        characteristics.forEach { subscribeTo(characteristic: $0) }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case characteristicTruconnectPeripheralRXUUID:
            guard let data = characteristic.value else { return }
            var values = [UInt8](data)
            data.copyBytes(to: &values, count: data.count)
            let responseString = String(bytes: data, encoding: .utf8)
            print("RX: \(String(describing: responseString))")
            break
        case characteristicTruconnectPeripheralTXUUID:
            guard let data = characteristic.value else { return }
            var values = [UInt8](data)
            data.copyBytes(to: &values, count: data.count)
            
            if let responseString = String(bytes: data, encoding: .utf8) {
//                parseResponse(responseString)
            }
            break
        case characteristicTruconnectModeUUID:
            guard let data = characteristic.value else { return }
            var values = [UInt8](data)
            data.copyBytes(to: &values, count: data.count)
            if let modeString = String(bytes: data, encoding: .utf8){
                print("New mode")
                print(String(describing: modeString))
            }
            break
        default:
            break
        }
    }
}


