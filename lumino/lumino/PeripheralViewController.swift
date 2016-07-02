//
//  BluetoothListViewController.swift
//  lumino
//
//  Created by takumi.kashima on 2016/06/27.
//  Copyright © 2016年 UNUUU. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController, CBPeripheralManagerDelegate {
    
    private var peripheralManager: CBPeripheralManager!
    private var peripheral: CBPeripheral!
    
    private let PERIPHERAL_UUID = "3D35AA18-ACC3-D0D5-1372-DD84E2B4A63F"
    private let SERVICE_UUID = "713D0000-503E-4C75-BA94-3148F18D941E"
    private let CHARACTERISTIC_WRITE_UUID = "713D0003-503E-4C75-BA94-3148F18D941E"
    
    @IBOutlet weak var textWroteData: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .PoweredOff:
            print("powered off")
            break
        case .PoweredOn:
            print("powered on")
            
            let serviceUUID = CBUUID(string: SERVICE_UUID)
            let service = CBMutableService(type: serviceUUID, primary: true)
            let characteristicUUID = CBUUID(string: CHARACTERISTIC_WRITE_UUID)
            let properties: CBCharacteristicProperties = [.Read, .Write]
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
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        
        if let error = error {
            print("サービス追加失敗！ error: \(error)")
            return
        }
        
        print("サービス追加成功！")
        
        peripheralManager.startAdvertising(nil)
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if let error = error {
            print("Failed... error: \(error)")
            return
        }
        
        print("Succeeded!")
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        
        for request in requests {
            
            if request.characteristic.UUID.isEqual(CBUUID(string: CHARACTERISTIC_WRITE_UUID)) {
                // CBCharacteristicのvalueに、CBATTRequestのvalueをセット
                let receivedData = NSString(data: request.value!, encoding: NSUTF8StringEncoding)
                textWroteData.text = receivedData! as String
            }
            
            // リクエストに応答
            peripheralManager.respondToRequest(request, withResult: .Success)
        }
        
        print("received write request")
    }
}
