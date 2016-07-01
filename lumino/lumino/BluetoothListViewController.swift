//
//  BluetoothListViewController.swift
//  lumino
//
//  Created by takumi.kashima on 2016/06/27.
//  Copyright © 2016年 UNUUU. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothListViewController: UIViewController , CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    // private let PERIPHERAL_UUID = "F94FBB25-D809-6BFC-911A-9D533ACC256F"
    private let PERIPHERAL_UUID = "3D35AA18-ACC3-D0D5-1372-DD84E2B4A63F"
    private let SERVICE_UUID = "713D0000-503E-4C75-BA94-3148F18D941E"
    private let CHARACTERISTIC_WRITE_UUID = "713D0002-503E-4C75-BA94-3148F18D941E"
    
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
            print("powered off")
            break
        case .PoweredOn:
            print("powered on")
            textProgress.text = "Peripheralの検索中"
            centralManager.scanForPeripheralsWithServices(nil, options: nil)
            break
        case .Resetting:
            print("resetting")
            break
        case .Unauthorized:
            print("unauthorized")
            break
        case .Unsupported:
            print("unsupported")
            break
        default:
            print("unknown")
            break
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("peripheral: \(peripheral)")
        print("name: \(peripheral.name)")
        print("UUID: \(peripheral.identifier.UUIDString)")
        print("advertisementData: \(advertisementData)")
        print("RSSI: \(RSSI)")

        if (PERIPHERAL_UUID == peripheral.identifier.UUIDString) {
            centralManager.stopScan()
            textProgress.text = "Peripheralへの接続中"
            self.peripheral = peripheral
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        let alert: UIAlertController = UIAlertController(title: "接続に失敗", message: "Peripheralへの接続に失敗しました", preferredStyle:  UIAlertControllerStyle.Alert)
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
            self.textProgress.text = "Peripheralの検索中"
            self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
        })
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        textProgress.text = "サービスの検索中"
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
                print("Cancel")
                self.textProgress.text = "Peripheralの検索中"
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
                print("Cancel")
                self.textProgress.text = "Peripheralの検索中"
                self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
            })
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        for service in peripheral.services! {
            textProgress.text = "Characteristicの検索中"
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error != nil {
            let alert: UIAlertController = UIAlertController(title: "検索に失敗", message: "Characteristicの検索に失敗しました", preferredStyle:  UIAlertControllerStyle.Alert)
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
                (action: UIAlertAction!) -> Void in
                print("Cancel")
                self.textProgress.text = "Peripheralの検索中"
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
                print("Cancel")
                self.textProgress.text = "Peripheralの検索中"
                self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
            })
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        for characteristic in service.characteristics! {
            self.textProgress.text = "\(characteristic.UUID.UUIDString)\n\(self.textProgress.text)"
            if (characteristic.UUID.UUIDString == CHARACTERISTIC_WRITE_UUID) {
                self.peripheral = peripheral
                self.characteristic = characteristic
                textProgress.text = "接続完了"
                navigateToMainViewController()
                return
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral,
                    didWriteValueForCharacteristic characteristic: CBCharacteristic,
                                                   error: NSError?)
    {
        let notification = UILocalNotification()
        if let error = error {
            notification.alertBody = "送信に失敗しました"
            print("Write失敗...error: \(error)")
        } else {
            notification.alertBody = "送信に成功しました"
            print("Write成功！")
        }
        notification.fireDate = NSDate()
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func navigateToMainViewController() {
        let mainViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")  as! ViewController
        mainViewController.peripheral = self.peripheral
        mainViewController.characteristic = self.characteristic
        self.presentViewController(mainViewController, animated: true, completion: nil)
    }
}
