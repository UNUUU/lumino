//
//  BluetoothListViewController.swift
//  lumino
//
//  Created by takumi.kashima on 2016/06/27.
//  Copyright © 2016年 UNUUU. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanViewController: UIViewController , CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    // private let PERIPHERAL_UUID = "F94FBB25-D809-6BFC-911A-9D533ACC256F"
    private let PERIPHERAL_UUID = "3D35AA18-ACC3-D0D5-1372-DD84E2B4A63F"
    private let SERVICE_UUID = "713D0000-503E-4C75-BA94-3148F18D941E"
    private let CHARACTERISTIC_WRITE_UUID = "713D0003-503E-4C75-BA94-3148F18D941E"
    
    @IBOutlet weak var textProgress: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOff:
            Logger.log("powered off")
            break
        case .PoweredOn:
            Logger.log("powered on")
            Logger.log("Peripheralの検索中")
            textProgress.selectable = true
            textProgress.text = "scanning peripherals..."
            textProgress.selectable = false
            centralManager.scanForPeripheralsWithServices(nil, options: nil)
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
            centralManager.stopScan()
            Logger.log("Peripheralへの接続中")
            textProgress.selectable = true
            textProgress.text = "connecting peripheral..."
            textProgress.selectable = false
            self.peripheral = peripheral
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        let alert: UIAlertController = UIAlertController(title: "接続に失敗", message: "Peripheralへの接続に失敗しました", preferredStyle:  UIAlertControllerStyle.Alert)
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
            Logger.log("Cancel")
            Logger.log("Peripheralの検索中")
            self.textProgress.selectable = true
            self.textProgress.text = "scanning peripherals..."
            self.textProgress.selectable = false
            self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
        })
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        Logger.log("サービスの検索中")
        textProgress.selectable = true
        textProgress.text = "scanning services..."
        textProgress.selectable = false
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        self.peripheral = nil
        self.characteristic = nil
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error != nil {
            let alert: UIAlertController = UIAlertController(title: "検索に失敗", message: "Serviceの検索に失敗しました", preferredStyle:  UIAlertControllerStyle.Alert)
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
                (action: UIAlertAction!) -> Void in
                Logger.log("Cancel")
                Logger.log("Peripheralの検索中")
                self.textProgress.selectable = true
                self.textProgress.text = "scanning peripherals..."
                self.textProgress.selectable = false
                self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
            })
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if (peripheral.services!.isEmpty) {
            let alert: UIAlertController = UIAlertController(title: "検索に失敗", message: "Serviceが見つかりませんでした", preferredStyle:  UIAlertControllerStyle.Alert)
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
                (action: UIAlertAction!) -> Void in
                Logger.log("Cancel")
                Logger.log("Peripheralの検索中")
                self.textProgress.selectable = true
                self.textProgress.text = "scanning peripherals..."
                self.textProgress.selectable = false
                self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
            })
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        for service in peripheral.services! {
            Logger.log("Service: \(service.UUID.UUIDString)")
            Logger.log("Characteristicの検索中")
            textProgress.selectable = true
            textProgress.text = "scanning characteristics..."
            textProgress.selectable = false
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error != nil {
            let alert: UIAlertController = UIAlertController(title: "検索に失敗", message: "Characteristicの検索に失敗しました", preferredStyle:  UIAlertControllerStyle.Alert)
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
                (action: UIAlertAction!) -> Void in
                Logger.log("Cancel")
                Logger.log("Peripheralの検索中")
                self.textProgress.selectable = true
                self.textProgress.text = "scanning peripherals..."
                self.textProgress.selectable = false
                self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
            })
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if (service.characteristics!.isEmpty) {
            let alert: UIAlertController = UIAlertController(title: "検索に失敗", message: "Characteristicが見つかりませんでした", preferredStyle:  UIAlertControllerStyle.Alert)
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
                (action: UIAlertAction!) -> Void in
                Logger.log("Cancel")
                Logger.log("Peripheralの検索中")
                self.textProgress.selectable = true
                self.textProgress.text = "scanning peripherals..."
                self.textProgress.selectable = false
                self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
            })
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        for characteristic in service.characteristics! {
            Logger.log("Characteristic: \(characteristic.UUID.UUIDString)")
            Logger.log("Permission:  \(characteristic.properties.rawValue)")
            if (characteristic.UUID.UUIDString == CHARACTERISTIC_WRITE_UUID) {
                self.peripheral = peripheral
                self.characteristic = characteristic
                Logger.log("接続完了")
                textProgress.selectable = true
                textProgress.text = "connection completed"
                textProgress.selectable = false
                navigateToMainViewController()
                return
            }
        }
    }
    
    func navigateToMainViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let mainViewController =  storyboard.instantiateInitialViewController() as! MainViewController
        mainViewController.peripheral = self.peripheral
        mainViewController.characteristic = self.characteristic
        self.presentViewController(mainViewController, animated: true, completion: nil)
    }
}
