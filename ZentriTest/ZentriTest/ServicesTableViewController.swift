//
//  ServicesTableViewController.swift
//  ZentriTest
//
//  Created by Michel on 16/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServicesTableViewController: UITableViewController {
    let serviceTruconnectUUID = CBUUID(string: "175f8f23-a570-49bd-9627-815a6a27de2a")
    let characteristicTruconnectPeripheralRXUUID = CBUUID(string: "1cce1ea8-bd34-4813-a00a-c76e028fadcb")
    let characteristicTruconnectPeripheralTXUUID = CBUUID(string: "cacc07ff-ffff-4c48-8fae-a9ef71b75e26")
    let characteristicTruconnectModeUUID = CBUUID(string: "20b9794f-da1a-4d14-8014-a0fb9cefb2f7")
    
    var streamMode = 1
    var remoteMode = 3
    
    let centralManager: CBCentralManager
    let peripheral :CBPeripheral
    
    var services: [CBService] = []
    var characteristics: [CBCharacteristic] = []
    
    var rxCharacteristic: CBCharacteristic?
    var txCharacteristic: CBCharacteristic?
    var modeCharacteristic: CBCharacteristic?
	
	var functionalities = Functionality.allCases
    
    init(manager: CBCentralManager, peripheral: CBPeripheral) {
        self.centralManager = manager
        self.peripheral = peripheral
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        connectPeripheral()
    }
    
    func setup() {
        self.title = "Characteristics"
        tableView.register(UINib(nibName: CharacteristicCell.identifier, bundle: .main), forCellReuseIdentifier: CharacteristicCell.identifier)
        tableView.rowHeight = 60.0
		tableView.isUserInteractionEnabled = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return functionalities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CharacteristicCell.identifier, for: indexPath) as! CharacteristicCell
		
        cell.nameLabel.text = functionalities[indexPath.row].name
        return cell
    }
    
    // MARK: - Table view delegate

	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let functionality = functionalities[indexPath.row]
		if let bapiJSON = functionality.createBapi(id: 123) {
			send(bapi: bapiJSON)
		}
    }

}

// MARK: - CBCentralManagerDelegate

extension ServicesTableViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        self.peripheral.delegate = self
        self.peripheral.discoverServices([serviceTruconnectUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected Peripheral: \(peripheral.name ?? "unknown")")
    }
}

// MARK: - CBPeripheralDelegate

extension ServicesTableViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first else { return }
        discoverCharacteristicsFor(service: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        self.characteristics = characteristics
        _ = characteristics.map{ subscribeTo(characteristic: $0) }
        self.tableView.reloadData()
		self.tableView.isUserInteractionEnabled = true
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
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
            let responseString = String(bytes: data, encoding: .utf8)
            print("TX: \(String(describing: responseString))")
            break
        case characteristicTruconnectModeUUID:
            guard let data = characteristic.value else { return }
            var values = [UInt8](data)
            data.copyBytes(to: &values, count: data.count)
            let modeString = String(bytes: data, encoding: .utf8)
            print("MODE: \(String(describing: modeString))")
            break
        default:
            break
        }
    }
}

//MARK: - Utils

extension ServicesTableViewController {
    fileprivate func connectPeripheral() {
        centralManager.connect(self.peripheral, options: nil)
        centralManager.delegate = self
    }
    
    fileprivate func discoverCharacteristicsFor(service: CBService) {
        self.peripheral.discoverCharacteristics(nil, for: service)
    }
	
    
    fileprivate func showModeActionSheet(characteristic: CBCharacteristic) {
        let alert = UIAlertController(title: "ZENTRI MODE", message: "Choose the mode", preferredStyle: .actionSheet)
        let actionStreamMode = UIAlertAction(title: "Stream mode",
                                             style: .default) { action in
                                                print("activate stream mode")
                                                self.writeStreamMode(characteristic: characteristic)
                                            }
        
        let actionRemoteMode = UIAlertAction(title: "Remote mode",
                                             style: .default) { action in
                                                print("activate remote mode")
                                                self.writeRemoteMode(characteristic: characteristic)
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        alert.addAction(actionStreamMode)
        alert.addAction(actionRemoteMode)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func subscribeTo(characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case characteristicTruconnectPeripheralRXUUID:
            rxCharacteristic = characteristic
        case characteristicTruconnectPeripheralTXUUID:
            txCharacteristic = characteristic
            self.peripheral.setNotifyValue(true, for: txCharacteristic!)
        case characteristicTruconnectModeUUID:
            modeCharacteristic = characteristic
            self.peripheral.setNotifyValue(true, for: modeCharacteristic!)
            break
        default:
            break
        }
    }
    
    
    fileprivate func writeStreamMode(characteristic: CBCharacteristic) {
        let data = Data(bytes: &streamMode,
                        count: 1)
        self.peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    fileprivate func writeRemoteMode(characteristic: CBCharacteristic) {
        let data = Data(bytes: &remoteMode,
                        count: 1)
        self.peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
	 func send(bapi: String) {
		
		let bapiCommand = parseData(bapiString: bapi)
       	guard let data = bapiCommand.data(using: .utf8) else { return }
		print("send bapi: \(bapiCommand)")

		let length = data.count
		let chunkSize = 20
		var offset = 0
		
		repeat {
			// get the length of the chunk
			let thisChunkSize = ((length - offset) > chunkSize) ? chunkSize : (length - offset);
			
			// get the chunk
			let chunk = data.subdata(in: offset..<offset + thisChunkSize )
			
			// -----------------------------------------------
			// do something with that chunk of data...
			// -----------------------------------------------
			self.peripheral.writeValue(chunk, for: rxCharacteristic!, type: .withResponse)
			// update the offset
			offset += thisChunkSize;
			
		} while (offset < length);
		
    }
    
    fileprivate func parseData(bapiString: String) -> String {
		
        let eaeCharacter = getCharacterFromCmd(order: bapiString)
        let bapi = eaeCharacter + bapiString
        let checksumNumber = getChecksum(order: bapi)
		
		
        var buf = [UInt8](String(bapi).utf8)
        buf.append(checksumNumber)
        let size = bapiString.utf8.count
        var eAE:[UInt8] = [UInt8](String("EaE").utf8)
        eAE.append(UInt8(size))
        let preCmdB:[UInt8] = eAE
        var bufB:[UInt8] = preCmdB + [UInt8](String(bapiString).utf8)
        let postCmdB = getChecksumBinary(order: bufB)
        bufB.append(postCmdB)
        
        let data = Data(bufB)
        guard let string = String(data: data, encoding: .utf8) else { return "" }
        
        return string + "\r\n"
    }
	
    
    func getCharacterFromCmd(order: String) -> String{
        let size = order.utf8.count
        return "EaE" + String(Character(UnicodeScalar(size)!))
    }
    
    func getChecksum(order: String) -> UInt8{
        var a: UInt32 = 0
        for scalar in order.unicodeScalars {
            a += scalar.value
        }
        let result = a % 256
        return UInt8(result)
    }
    
    func getChecksumBinary(order: [UInt8]) -> UInt8{
        var a: UInt32 = 0
        for item in order {
            a += UInt32(item)
        }
        let result = a % 256
        return UInt8(result)
    }
}
