//
//  PeripheralCell.swift
//  ZentriTest
//
//  Created by Michel on 16/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol PeripheralCellDelegate: class {
    func didTapConnection(cell: PeripheralCell, peripheral: CBPeripheral)
}

class PeripheralCell: UITableViewCell {
    static let identifier = "PeripheralCell"

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var connectionButton: UIButton!
    
    weak var delegate: PeripheralCellDelegate?
    
    var peripheral: CBPeripheral?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uuidLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureWith(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.nameLabel.text = peripheral.name
        self.uuidLabel.text = peripheral.identifier.description
    }
    
    
    @IBAction func connectionAction(_ sender: Any) {
        if let peripheral = self.peripheral {
            delegate?.didTapConnection(cell: self, peripheral: peripheral)
        }
    }
    
}
