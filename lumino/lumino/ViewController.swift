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
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
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
        case CBCentralManagerState.PoweredOff:
            print("powered off")
            break
        case CBCentralManagerState.PoweredOn:
            print("powered on")
            break
        case CBCentralManagerState.Resetting:
            print("resetting")
            break
        case CBCentralManagerState.Unauthorized:
            print("unauthorized")
            break
        case CBCentralManagerState.Unsupported:
            print("unsupported")
            break
        default:
            print("unknown")
            break
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("peripheral: \(peripheral)")
        centralManager.stopScan()
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    }
}

