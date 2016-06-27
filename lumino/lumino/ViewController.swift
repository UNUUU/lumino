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

class ViewController: UIViewController {
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    private let deviceId: String? = UIDevice.currentDevice().identifierForVendor?.UUIDString
    
    @IBOutlet weak var textDeviceId: UITextView!
    
    @IBAction func onTouchButtonWaooooo(sender: AnyObject) {
        writeMessage("Waooooo")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.onReceiveMessage), name: "onReceiveMessage", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        textDeviceId.text = deviceId
    }
    
    func onReceiveMessage(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let message = userInfo["message"]! as! String
        print("received message: \(message)")
        writeMessage(message)
    }
    
    private func writeMessage(message: String) {
        if (peripheral != nil && characteristic != nil) {
            print("wrote message \(message)")
            let data = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:true)
            peripheral!.writeValue(data!, forCharacteristic: characteristic!, type: CBCharacteristicWriteType.WithResponse)
        }
    }
}

