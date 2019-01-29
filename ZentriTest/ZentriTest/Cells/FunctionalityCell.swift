//
//  CharacteristicCell.swift
//  ZentriTest
//
//  Created by Michel on 17/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import UIKit

class FunctionalityCell: UITableViewCell {
    static let identifier = "CharacteristicCell"
    
    @IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var okLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.adjustsFontSizeToFitWidth = true
		okLabel.layer.cornerRadius = okLabel.frame.width
		okLabel.backgroundColor = .red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
