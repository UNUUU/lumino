//
//  BluetoothListViewController.swift
//  lumino
//
//  Created by takumi.kashima on 2016/06/27.
//  Copyright © 2016年 UNUUU. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothListViewController: UIViewController , UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    private let SERVICE_UUID = "3D35AA18-ACC3-D0D5-1372-DD84E2B4A63F"
    private let CHARACTERISTIC_WRITE_UUID = "3D35AA18-ACC3-D0D5-1372-DD84E2B4A63F"
    
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

        if (SERVICE_UUID == peripheral.identifier.UUIDString) {
            centralManager.stopScan()
            textProgress.text = "Peripheralへの接続中"
            self.peripheral = peripheral
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func navigateToMainViewController(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        let mainViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")  as! ViewController
        mainViewController.peripheral = peripheral
        mainViewController.characteristic = characteristic
        self.presentViewController(mainViewController, animated: true, completion: nil)
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
        peripheral.discoverServices([CBUUID(string: self.SERVICE_UUID)])
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
        
        // 今回は特注なので1つしかサービスがない前提で進める
        textProgress.text = "Characteristicの検索中"
        peripheral.discoverCharacteristics([CBUUID(string: CHARACTERISTIC_WRITE_UUID)], forService: peripheral.services![0])
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
        
        let characteristics = service.characteristics
        print("Found \(characteristics!.count) characteristics! : \(characteristics)")
        var characteristic: CBCharacteristic? = nil
        characteristics?.filter { characteristic in
            characteristic.properties.rawValue & CBCharacteristicProperties.Write.rawValue != 0
        }.forEach {
            characteristic = $0
            return
        }
        
        guard let writeCharacteristic = characteristic else {
            let alert: UIAlertController = UIAlertController(title: "アラート表示", message: "書き込み権限があるcharacteristicを見つけられませんでした", preferredStyle:  UIAlertControllerStyle.Alert)
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
                self.textProgress.text = "Peripheralの検索中"
                self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
            })
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        textProgress.text = "接続完了"
        navigateToMainViewController(peripheral, characteristic: writeCharacteristic)
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
}
