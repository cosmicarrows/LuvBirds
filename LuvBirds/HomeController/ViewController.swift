//
//  ViewController.swift
//  LuvBirds
//
//  Created by Laurence Wingo on 8/23/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import UIKit
import QuartzCore
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {

    @IBOutlet var fighterButton: UIButton!
    @IBOutlet var loverButton: UIButton!
    @IBOutlet var bluetoothPowerButton: UIButton!
    var centralManager: CBCentralManager!
    var isBlueToothEnabled: Bool = false
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBlueToothEnabled = true
            bluetoothPowerButton.setTitle("BlueTooth On", for: .normal)
            break
        case .poweredOff:
            isBlueToothEnabled = false
            bluetoothPowerButton.setTitle("BlueTooth Off", for: .normal)
            break
        default:
            print("Hello from the default statment")
            break
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier ==  kCentralRoleSegue || identifier == kPeripheralRoleSegue{
            if !isBlueToothEnabled {
                showAlertForSettings()
                return false
            }
        }
        return true
    }
    
    func showAlertForSettings(){
        let alertController = UIAlertController.init(title: "LuvBirds", message: "Turn On BlueTooth to Connect to Send and Receive Messages", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction.init(title: "Settings", style: .cancel) { (action) in
            let url = NSURL.init(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
            //do nothing
        }
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
        bluetoothPowerButton.backgroundColor = UIColor.clear
        bluetoothPowerButton.layer.cornerRadius = 20.0
        bluetoothPowerButton.setTitle("Enable LuvBirds", for: .normal)
        bluetoothPowerButton.setTitleColor(UIColor.white, for: .normal)
        fighterButton.layer.cornerRadius = 20.0
        loverButton.layer.cornerRadius = 20.0
        fighterButton.setTitle("FIGHTER - PERIPHERIAL ROLE", for: .normal)
        loverButton.setTitle("LOVER - CENTRAL ROLE", for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

