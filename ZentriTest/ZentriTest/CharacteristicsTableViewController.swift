//
//  CharacteristicsTableViewController.swift
//  ZentriTest
//
//  Created by Michel on 16/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicsTableViewController: UITableViewController {
    
    let peripheral: CBPeripheral
    let service: CBService
    
    var characteristics: [CBCharacteristic] = []
    
    init(peripheral: CBPeripheral, service: CBService) {
        self.peripheral = peripheral
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        discoverCharacteristitcs()
    }
    
    func setup() {
        self.title = "CHARACTERISTICS"
        tableView.register(UINib(nibName: CharacteristicCell.identifier, bundle: .main), forCellReuseIdentifier: CharacteristicCell.identifier)
        tableView.rowHeight = 60.0
    }
    
    func discoverCharacteristitcs() {
        self.peripheral.delegate = self
        self.peripheral.discoverCharacteristics(nil, for: self.service)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CharacteristicCell.identifier, for: indexPath) as! CharacteristicCell
        let characteristic = self.characteristics[indexPath.row]
        cell.nameLabel.text = characteristic.uuid.uuidString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let characteristic = self.characteristics[indexPath.row]
        if characteristic.properties.contains(.read) {
            print("\(characteristic.uuid): properties contains .read")
        }
        if characteristic.properties.contains(.notify) {
            print("\(characteristic.uuid): properties contains .notify")
        }
        if characteristic.properties.contains(.write) {
            print("\(characteristic.uuid): properties contains .write")
        }
        if characteristic.properties.contains(.indicateEncryptionRequired) {
            print("\(characteristic.uuid): properties contains .indicateEncryptionRequired")
        }
    }

}

extension CharacteristicsTableViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        self.characteristics = characteristics
        self.tableView.reloadData()
    }
}
