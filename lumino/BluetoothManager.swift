//
//  BluetoothManager.swift
//  lumino
//
//  Created by takumi.kashima on 7/7/16.
//  Copyright © 2016 UNUUU. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol OnBluetoothInteractionListener {
    func scanningPeripheral()
    func connectingPeripheral()
    func scanningService()
    func didFailToConnectPeripheral()
    func didDisconnectPeripheral()
    func didFailToDiscoverService()
    func scanningCharacteristic()
    func didFailToDiscoverCharacteristic()
    func completedConnection()
}

class BluetoothManager : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static var sharedManager: BluetoothManager = {
        return BluetoothManager()
    }()
    
    private var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    var listener: OnBluetoothInteractionListener? = nil
    
    // private let PERIPHERAL_UUID = "F94FBB25-D809-6BFC-911A-9D533ACC256F"
    private let PERIPHERAL_UUID = "3D35AA18-ACC3-D0D5-1372-DD84E2B4A63F"
    private let SERVICE_UUID = "713D0000-503E-4C75-BA94-3148F18D941E"
    private let CHARACTERISTIC_WRITE_UUID = "713D0003-503E-4C75-BA94-3148F18D941E"
    
    private override init() {
        super.init()
        
    }
    
    func startScan() {
        if (centralManager != nil) {
            stopScan()
        }
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func stopScan() {
        centralManager?.stopScan()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOff:
            Logger.log("powered off")
            break
        case .PoweredOn:
            Logger.log("powered on")
            Logger.log("Peripheralの検索中")
            listener?.scanningPeripheral()
            centralManager?.scanForPeripheralsWithServices(nil, options: nil)
            break
        case .Resetting:
            Logger.log("resetting")
            break
        case .Unauthorized:
            Logger.log("unauthorized")
            break
        case .Unsupported:
            Logger.log("unsupported")
            break
        default:
            Logger.log("unknown")
            break
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        Logger.log("peripheral: \(peripheral)")
        Logger.log("name: \(peripheral.name)")
        Logger.log("UUID: \(peripheral.identifier.UUIDString)")
        Logger.log("advertisementData: \(advertisementData)")
        Logger.log("RSSI: \(RSSI)")
        
        if (PERIPHERAL_UUID == peripheral.identifier.UUIDString) {
            centralManager?.stopScan()
            self.peripheral = peripheral
            listener?.connectingPeripheral()
            centralManager?.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        Logger.log("サービスの検索中")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        listener?.didFailToConnectPeripheral()
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        self.peripheral = nil
        self.characteristic = nil

        listener?.didDisconnectPeripheral()
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error != nil {
            listener?.didFailToDiscoverService()
            return
        }
        
        if (peripheral.services!.isEmpty) {
            listener?.didFailToDiscoverService()
            return
        }
        
        for service in peripheral.services! {
            Logger.log("Service: \(service.UUID.UUIDString)")
            Logger.log("Characteristicの検索中")
            listener?.scanningCharacteristic()
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error != nil {
            listener?.didFailToDiscoverCharacteristic()
            return
        }
        
        if (service.characteristics!.isEmpty) {
            listener?.didFailToDiscoverCharacteristic()
            return
        }
        
        for characteristic in service.characteristics! {
            Logger.log("Characteristic: \(characteristic.UUID.UUIDString)")
            Logger.log("Permission:  \(characteristic.properties.rawValue)")
            if (characteristic.UUID.UUIDString == CHARACTERISTIC_WRITE_UUID) {
                self.peripheral = peripheral
                self.characteristic = characteristic
                Logger.log("接続完了")
                listener?.completedConnection()
                return
            }
        }
    }
}
