//
//  BluetoothListViewController.swift
//  lumino
//
//  Created by takumi.kashima on 2016/06/27.
//  Copyright © 2016年 UNUUU. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothListViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate {
    
    private let peripheralList: NSMutableArray = []

    private var centralManager: CBCentralManager!
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        peripheralList.addObject(PeripheralEntity(peripheral: peripheral, localName: advertisementData["kCBAdvDataLocalName"] as? String))
        
        tableView.reloadData()
    }
    
    func tableView(table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralList.count
    }
    
    func tableView(table: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        let textView = table.viewWithTag(1) as! UITextView
        let peripheralEntity = peripheralList[indexPath.row] as! PeripheralEntity
        var localName = ""
        if (peripheralEntity.localName != nil) {
            localName = peripheralEntity.localName!
        }
        textView.text = "\(peripheralEntity.peripheral.name!) (\(localName))"
        
        return cell
    }
}
