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

class ViewController: UIViewController, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonScan: UIButton!
    
    @IBAction func onTouchButtonScan(sender: AnyObject) {
        print("onTouchButtonScan")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func onTouchPeripheral(sender: AnyObject) {
    }
    
    private let deviceId: String? = UIDevice.currentDevice().identifierForVendor?.UUIDString

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("deviceId: \(deviceId)")
        
        registerNotificationToken("123456")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func registerNotificationToken(token: String) {
        guard let deviceId = deviceId else {
            print("not found device id")
            return
        }
        indicator.hidden = false
        Alamofire.request(.PUT, "https://lumino.herokuapp.com/\(deviceId)/notification", parameters: ["token": token]).responseString {
            response in
            self.indicator.hidden = true
            print("statusCode: \(response.response?.statusCode)")
            if response.result.isFailure {
                print("failed put device id")
                return
            }
            print("success \(response.result.value)")
        }
    }
        
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOff:
            print("powered off")
            break
        case .PoweredOn:
            print("powered on")
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
        
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("connection failed")
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("connection success!")
    }
}

