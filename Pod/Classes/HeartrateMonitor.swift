//
//  HeartrateMonitor.swift
//  btle-heartrate
//
//  Created by Michael Kuehl on 29.03.15.
//  Copyright (c) 2015 Michael Kuehl. All rights reserved.
//

import Foundation
import CoreBluetooth

// clients using this library must implement this protocol to receive HR updates
protocol HeartrateCallback {
    func updateMeasurement(flags: UInt8, value: UInt8, data: NSData)
}

//
// details on how to use data received by a BLE heartrate monitor can be found here:
//
// https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.heart_rate_measurement.xml
//

class HeartrateMonitor: BluetoothConnector, CBPeripheralDelegate {
    
    let HEARTRATE_SERVICE = CBUUID(string: "180D")
    let HEARTRATE_MEASUREMENT = CBUUID(string: "2A37")
    
    private var delegate: HeartrateCallback!
    
    init(delegate: HeartrateCallback) {
        super.init()
        self.delegate = delegate
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!){
        peripheral.delegate = self
        peripheral.discoverServices(services)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!){
        for service in peripheral.services {
            if service.UUID == HEARTRATE_SERVICE {
                peripheral.discoverCharacteristics([HEARTRATE_MEASUREMENT], forService: service as CBService)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if service.UUID == HEARTRATE_SERVICE {
            for characteristic in service.characteristics {
                peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        var flags : UInt8 = 0
        var hr : UInt8 = 0
        
        let data = characteristic.value as NSData
        
        // extract basic stuff
        data.getBytes(&flags, range: NSMakeRange(0, 1))
        data.getBytes(&hr, range: NSMakeRange(1, 1))
        
        // callback
        delegate.updateMeasurement(flags, value: hr, data: data)
        
    }
    
}