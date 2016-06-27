//
//  BluetoothListViewController.swift
//  lumino
//
//  Created by takumi.kashima on 2016/06/27.
//  Copyright © 2016年 UNUUU. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothListViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var peripheralList: [PeripheralEntity] = []

    private var centralManager: CBCentralManager!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        centralManager.stopScan()
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
            // let serviceUUIDs:[CBUUID] = [CBUUID(string: "lumino")]
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
        
        let uuid = peripheral.identifier.UUIDString
        let localName = advertisementData["kCBAdvDataLocalName"] as! String? ?? ""
        
        var isAlreadyContainPeripheral = false
        peripheralList.forEach { peripheralEntity in
            if (peripheralEntity.uuid == uuid) {
                peripheralEntity.peripheral = peripheral
                peripheralEntity.localName = localName
                isAlreadyContainPeripheral = true
                return
            }
        }
        
        if (!isAlreadyContainPeripheral) {
            peripheralList.append(PeripheralEntity(uuid: uuid, peripheral: peripheral, localName: localName))
        }

        tableView.reloadData()
    }
    
    func tableView(table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralList.count
    }
    
    func tableView(table: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        let textView = table.viewWithTag(1) as! UITextView
        let peripheralEntity = peripheralList[indexPath.row]
        textView.text = "\(peripheralEntity.peripheral.name) (\(peripheralEntity.localName))"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let peripheralEntity = peripheralList[indexPath.row]
        centralManager.stopScan()
//        navigateToMainViewController(peripheralEntity)
        centralManager.connectPeripheral(peripheralEntity.peripheral, options: nil)
    }
    
    func navigateToMainViewController(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        let mainViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")  as! ViewController
        mainViewController.peripheral = peripheral
        mainViewController.characteristic = characteristic
        self.presentViewController(mainViewController, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("connection failed")
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("connection success!")
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        let services = peripheral.services
        print("Found \(services!.count) services! :\(services)")
        
//        for service in services! {
//            if (service.UUID.isEqual(CBUUID(string: "FEE3394A-8122-4BED-8510-59FB1C09F96F"))) {
            
//            }
//        }
        peripheral.discoverCharacteristics(nil, forService: services![0])
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        let characteristics = service.characteristics
        print("Found \(characteristics!.count) characteristics! : \(characteristics)")
        navigateToMainViewController(peripheral, characteristic: characteristics![0])
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
