//
//  ViewController.swift
//  ZentriTest
//
//  Created by Michel on 16/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import UIKit
import CoreBluetooth
import WallboxBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var centralManager: CBCentralManager!
    
    var peripherals: [CBPeripheral] = []
    
    let wallboxBluetooth = WallboxBluetooth()
    
    var devices: [WallboxDevice] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
//        initBluetoothServices()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wallboxBluetooth.startScan(deviceFound: { [unowned self] (device) in
            print("device found: \(device.name ?? "")")
            self.devices.append(device)
            self.devices = self.devices.sorted{ $0.name! < $1.name! }
            self.tableView.reloadData()
        }) { (error) in
            print(error)
        }
    }
	
	override func viewDidAppear(_ animated: Bool) {
		tableView.reloadData()
	}

    func setup() {
        self.title = "ZENTRI"
        tableView.register(UINib(nibName: PeripheralCell.identifier, bundle: .main), forCellReuseIdentifier: PeripheralCell.identifier)
        tableView.rowHeight = 60.0
    }
    
    func initBluetoothServices() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PeripheralCell.identifier, for: indexPath) as! PeripheralCell
        let device = devices[indexPath.row]
        cell.delegate = self
        cell.nameLabel.text = device.name ?? "unknown"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = devices[indexPath.row]
        self.wallboxBluetooth.stopScan()
        let deviceVC = DeviceViewController(bluetooth: self.wallboxBluetooth, device: device)
        self.navigationController?.pushViewController(deviceVC, animated: true)
        
        
//        let servicesVC = ServicesTableViewController(manager: self.centralManager,
//                                                     peripheral: peripheral)
//        self.navigationController?.pushViewController(servicesVC, animated: true)
    }
}

extension ViewController: PeripheralCellDelegate {
    func didTapConnection(cell: PeripheralCell, peripheral: CBPeripheral) {
        centralManager.stopScan()
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "175f8f23-a570-49bd-9627-815a6a27de2a")])
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name,
            name.prefix(2) == "WB" {
                peripherals.append(peripheral)
                peripherals = peripherals.sorted{ $0.name! < $1.name! }
                tableView.reloadData()
        }
    }
}


