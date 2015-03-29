//
//  BluetoothConnector.swift
//  btle-heartrate
//
//  Created by Michael Kuehl on 29.03.15.
//  Copyright (c) 2015 Michael Kuehl. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothConnector: NSObject, CBCentralManagerDelegate {
    
    var services = nil as [CBUUID]!
    
    private var cm : CBCentralManager!
    private var device = nil as CBPeripheral?
    
    override init() {
        super.init()
    }
    
    init(services: [CBUUID]) {
        self.services = services
    }
    
    func startDiscovery() {
        cm = CBCentralManager(delegate: self, queue: nil)
    }
    
    func stopDiscovery() {
        cm.stopScan()
    }
    
    //
    // delegate functions
    //
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        if(self.device == nil) {
            device = peripheral;
            central.connectPeripheral(peripheral, options: nil);
        }
    }
    
    func centralManager(central: CBCentralManager!, didRetrieveConnectedPeripherals peripherals: [AnyObject]!){
        //println("didRetrieveConnectedPeripherals peripherals: \(peripherals.description)")
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!){
        //println("didFailToConnectPeripheral \(peripheral) error:\(error)")
        
        self.device = nil
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!){
        //println("didDisconnectPeripheral \(peripheral) error:\(error)")
        
        self.device = nil
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        switch (central.state) {
            
        case .PoweredOff:
            self.device = nil
            
        case .PoweredOn:
            cm.scanForPeripheralsWithServices(nil, options: nil)
            
        case .Resetting:
            self.device = nil
            
        case .Unauthorized:
            println("CoreBluetooth BLE state is unauthorized")
            
        case .Unknown:
            println("CoreBluetooth BLE state is unknown")
            
        case .Unsupported:
            println("CoreBluetooth BLE hardware is unsupported on this platform")
            
        }
        
    }
}