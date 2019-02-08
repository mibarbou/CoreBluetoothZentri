//
//  DeviceViewController.swift
//  ZentriTest
//
//  Created by Michel on 08/02/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import UIKit
import WallboxBluetooth

class DeviceViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var zentriModeLabel: UILabel!
    @IBOutlet weak var blockUnblockButton: UIButton!
    
    let bluetooth: WallboxBluetooth
    var device: WallboxDevice
    
    init(bluetooth: WallboxBluetooth, device: WallboxDevice) {
        self.bluetooth = bluetooth
        self.device = device
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        bluetooth.connect(device: device,
                                 success: { (device) in
                                    self.activityIndicator.stopAnimating()
                                    self.title = device.name
                                    print("device connected: \(device.name ?? "")")
                                    self.device = device
        }, failure: { (error) in
            self.activityIndicator.stopAnimating()
            print(error)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bluetooth.disconnect(device: self.device,
                             success: { (device) in
                                print("device disconnected: \(device.name ?? "")")
        }) { (error) in
            print(error)
        }
    }
    
    
    @IBAction func blockUnblockAction(_ sender: Any) {
        
    }

}
