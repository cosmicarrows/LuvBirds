//
//  TransferServiceScanner.swift
//  LuvBirds
//
//  Created by Laurence Wingo on 8/30/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import Foundation
import CoreBluetooth
import EstimoteProximitySDK

protocol TransferServiceScannerDelegateProtocol: NSObjectProtocol {
    func didStartScan()
    func didStopScan()
    func didTransferData(data: NSData?)
}


class TransferServiceScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ESTDeviceManagerDelegate, ESTDeviceConnectableDelegate {
    
  
    
    
    var estimoteCentralManager: ESTDeviceManager!
    var device: ESTDeviceLocationBeacon?
    
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var data = NSMutableData()
    weak var delegate: TransferServiceScannerDelegateProtocol?
    weak var estDeviceConnectabledelegate: ESTDeviceConnectableDelegate?
    
    init(delegate: TransferServiceScannerDelegateProtocol?) {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        estimoteCentralManager = ESTDeviceManager.init()
        self.delegate = delegate
        estimoteCentralManager.delegate = self
        self.estDeviceConnectabledelegate = self
        
    }
    
    
    //start of cbCentralDelegate method
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Central is powered on...")
            break
        case .poweredOff:
            print("Central is powered off...computer stop scanning now")
            stopScan()
            break
        default:
            print("Central manager changed state \(central.state)")
            break
        }
    }
    //end of cbCentralDelegate method
    
    func startScan(){
        print("Start scan")
        let purpleEstimote = CBUUID.init(string: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        let iceMintEstimote = CBUUID.init(string: "A199712D-7BD4-2342-8268-F5376F811452")
        let mintGreenEstimote = CBUUID.init(string: "B52CE5B4-5BA5-969C-471D-012614F18EAD")
        let anotherEstimote = CBUUID.init(string: "7887B55D-4BBE-291A-A6CF-DB423D12E6F3")
        let fjsu = CBUUID.init(nsuuid: UUID.init(uuidString: "B52CE5B4-5BA5-969C-471D-012614F18EAD")!)
        let ans = CBUUID.init(nsuuid: UUID.init(uuidString: "7887B55D-4BBE-291A-A6CF-DB423D12E6F3")!)
        //let services = [CBUUID(string: kTransferServiceUUID)]
        let services = [purpleEstimote, iceMintEstimote, mintGreenEstimote, anotherEstimote, ans, fjsu]
        let options = Dictionary(dictionaryLiteral: (CBCentralManagerScanOptionAllowDuplicatesKey, false))
        //let options = Dictionary(dictionaryLiteral: (CBCentralManagerScanOptionSolicitedServiceUUIDsKey, false))
        //centralManager.scanForPeripherals(withServices: nil, options: options)
        //centralManager.scanForPeripherals(withServices: services, options: nil)
        if let deviceIdentifier = device?.identifier{
            let deviceFilter = ESTDeviceFilterLocationBeacon(
                identifier: deviceIdentifier)
            estimoteCentralManager.startDeviceDiscovery(with: deviceFilter)
        }
        
        
        //start of estimote sdk
        
        estimoteCentralManager.startDeviceDiscovery(with: ESTDeviceFilterLocationBeacon())
        
        delegate?.didStartScan()
    }
    
    func stopScan(){
        print("Stop scan")
        estimoteCentralManager.stopDeviceDiscovery()
        //centralManager.stopScan()
        delegate?.didStopScan()
    }
    
    func deviceManager(_ manager: ESTDeviceManager, didDiscover devices: [ESTDevice]) {
        print("Found an estimote!")
        let nextGenBeacons = devices as! [ESTDeviceLocationBeacon]
        let nearestBeacon = nextGenBeacons
            .map { ($0, ($0.identifier, RSSI: $0.rssi)) }
            .filter { $0.1.RSSI > -15 || $0.1.RSSI < -35 }
            .max { $0.1 < $1.1 }?.0
        if let nearestBeacon = nearestBeacon {
            print("nearestBeacon shows: \(nearestBeacon.identifier)")
            //nearestBeacon.connectForStorageRead()
            
            device = nearestBeacon
            estimoteCentralManager.stopDeviceDiscovery()

            self.device!.delegate = self
            self.device!.connect()
            
            
            /*
            let deviceIdentifier = nearestBeacon.identifier
            let deviceFilter = ESTDeviceFilterLocationBeacon(
                identifier: deviceIdentifier)
            estimoteCentralManager.startDeviceDiscovery(with: deviceFilter)
 */
            
            
        }
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("didDiscoverPeripheral \(peripheral)")
        
        /*
        // reject if above reasonable range, or too low
        if (RSSI.intValue > -15) || (RSSI.intValue < -35) {
            print("not in range, RSSI is \(RSSI.intValue)")
            return;
        }
        
        if (discoveredPeripheral != peripheral) {
            discoveredPeripheral = peripheral
            
            print("connecting to peripheral \(peripheral)")
            centralManager.connect(peripheral, options: nil)
        }
 */
    }
    
    func estDeviceConnectionDidSucceed(_ device: ESTDeviceConnectable) {
        print("connection succeeded!")
        stopScan()
        /*
        let storageContent: Dictionary = ["message" : "Hello My Love"]
        self.device?.storage?.saveStorageDictionary(storageContent, withCompletion: { (error) in
            if let error = error{
                print("there was an error: \(error)")
            }
            print("Storaged saved successfully")
        })
        */
        
        
        /*
        self.device?.settings?.deviceInfo.name.writeValue("plum", completion: { (name, error) in
            if let error = error{
                print("There was an error, here it is: \(error)")
            }else{
                print("success, here is the new name for the estimote: \(name)")
            }
        })
        
        */
        
        
        if let beaconColor = self.device?.settings?.deviceInfo.name.getValue(){
            switch beaconColor {
            case "blueberry":
                print("Found blueberry...")
                break
            case "mint":
                print("Found mint...")
                break
            default:
                print("Some random color found and it is: \(beaconColor)")
                break
            }
        }
 
    }
    
    
    
    func estDevice(_ device: ESTDeviceConnectable, didFailConnectionWithError error: Error) {
        print("connection failed, here is the error: \(error)")
    }
    
    func estDevice(_ device: ESTDeviceConnectable, didDisconnectWithError error: Error?) {
        print("disconnected from estimote")
    }
    
}
