//
//  ServiceCell.swift
//  ZentriTest
//
//  Created by Michel on 17/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import UIKit

class ServiceCell: UITableViewCell {
    static let identifier = "ServiceCell"

    @IBOutlet weak var identifierLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
