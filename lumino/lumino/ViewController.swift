//
//  ViewController.swift
//  lumino
//
//  Created by takumi.kashima on 2016/06/25.
//  Copyright © 2016年 UNUUU. All rights reserved.
//

import UIKit
import Alamofire
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonScan: UIButton!
    
    @IBAction func onTouchButtonScan(sender: AnyObject) {
        print("onTouchButtonScan")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func onTouchPeripheral(sender: AnyObject) {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    private let deviceId: String? = UIDevice.currentDevice().identifierForVendor?.UUIDString

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("deviceId: \(deviceId)")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.receivedMessage), name: "receivedMessage", object: nil)
    }
    
    func receivedMessage(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let message = userInfo["message"]! as! String
        print("received message: \(message)")
        writeMessage(message)
    }
    
    private func writeMessage(message: String) {
        if (peripheral != nil && characteristic != nil) {
            let data = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:true)
            peripheral!.writeValue(data!, forCharacteristic: characteristic!, type: CBCharacteristicWriteType.WithResponse)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        centralManager.stopScan()
        
        self.peripheral = peripheral
        
        centralManager.connectPeripheral(peripheral, options: nil)
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
        
        for service in services! {
            if (service.UUID.isEqual(CBUUID(string: "FEE3394A-8122-4BED-8510-59FB1C09F96F"))) {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        let characteristics = service.characteristics
        print("Found \(characteristics!.count) characteristics! : \(characteristics)")
        for characteristic in characteristics! {
            if (characteristic.UUID.isEqual(CBUUID(string: "C8AF1B19-BCEA-40EC-9B3C-D7992E4E131B"))) {
                self.characteristic = characteristic
                writeMessage("hello")
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral,
                    didWriteValueForCharacteristic characteristic: CBCharacteristic,
                                                   error: NSError?)
    {
        if let error = error {
            print("Write失敗...error: \(error)")
            return
        }
        
        print("Write成功！")
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .PoweredOff:
            print("powered off")
            break
        case .PoweredOn:
            print("powered on")
            
            let serviceUUID = CBUUID(string: "FEE3394A-8122-4BED-8510-59FB1C09F96F")
            let service = CBMutableService(type: serviceUUID, primary: true)
            let characteristicUUID = CBUUID(string: "C8AF1B19-BCEA-40EC-9B3C-D7992E4E131B")
            let properties: CBCharacteristicProperties = [.Notify, .Read, .Write]
            let permissions: CBAttributePermissions = [.Readable, .Writeable]
            let characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: properties,
                                                         value: nil, permissions: permissions)
            service.characteristics = [characteristic]
            peripheralManager.addService(service)
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
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if let error = error {
            print("Failed... error: \(error)")
            return
        }
        
        print("Succeeded!")
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        
        if let error = error {
            print("サービス追加失敗！ error: \(error)")
            return
        }
        
        print("サービス追加成功！")
        
        let advertisementData = [CBAdvertisementDataLocalNameKey: "Test Device"]
        peripheralManager.startAdvertising(advertisementData)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        
        for request in requests {
            
            if request.characteristic.UUID.isEqual(CBUUID(string: "C8AF1B19-BCEA-40EC-9B3C-D7992E4E131B")) {
                // CBCharacteristicのvalueに、CBATTRequestのvalueをセット
                let receivedData = NSString(data: request.value!, encoding: NSUTF8StringEncoding)
                print("received data: \(receivedData)")
            }
            
            // リクエストに応答
            peripheralManager.respondToRequest(request, withResult: .Success)
        }
        
        print("received write request")
    }
}

