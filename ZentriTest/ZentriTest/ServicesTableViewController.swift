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
    
    let centralManager: CBCentralManager
    let peripheral :CBPeripheral
    
    var services: [CBService] = []
    
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
        self.title = "SERVICES"
        tableView.register(UINib(nibName: ServiceCell.identifier, bundle: .main), forCellReuseIdentifier: ServiceCell.identifier)
        tableView.rowHeight = 60.0
    }
    
    func connectPeripheral() {
        centralManager.connect(self.peripheral, options: nil)
        centralManager.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ServiceCell.identifier, for: indexPath) as! ServiceCell
        let service = services[indexPath.row]
        cell.identifierLabel.text = service.uuid.uuidString
        return cell
    }
    
    // MARK: - Table view delegate
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let service = services[indexPath.row]
        let characteristicsVC = CharacteristicsTableViewController(peripheral: self.peripheral,
                                                                   service: service)
        self.navigationController?.pushViewController(characteristicsVC, animated: true)
    }

}

extension ServicesTableViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        peripheral.discoverServices(nil)
        peripheral.delegate = self
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

extension ServicesTableViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        self.services = services
        self.tableView.reloadData()
    }
}
