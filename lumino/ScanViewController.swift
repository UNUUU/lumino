//
//  BluetoothListViewController.swift
//  lumino
//
//  Created by takumi.kashima on 2016/06/27.
//  Copyright © 2016年 UNUUU. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanViewController: UIViewController, OnBluetoothInteractionListener {
    
    @IBOutlet weak var textProgress: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        BluetoothManager.sharedManager.listener = self
        BluetoothManager.sharedManager.startScan()
    }
    
    func navigateToMainViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let mainViewController =  storyboard.instantiateInitialViewController() as! MainViewController
        self.presentViewController(mainViewController, animated: true, completion: nil)
    }
    
    func scanningPeripheral() {
        textProgress.selectable = true
        textProgress.text = "scanning peripherals..."
        textProgress.selectable = false
    }
    
    func connectingPeripheral() {
        Logger.log("Peripheralへの接続中")
        textProgress.selectable = true
        textProgress.text = "connecting peripheral..."
        textProgress.selectable = false
    }
    
    func scanningService() {
        textProgress.selectable = true
        textProgress.text = "scanning services..."
        textProgress.selectable = false
    }
    
    func didFailToConnectPeripheral() {
        let alert: UIAlertController = UIAlertController(title: "接続に失敗", message: "Peripheralへの接続に失敗しました", preferredStyle:  UIAlertControllerStyle.Alert)
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
            Logger.log("Cancel")
            Logger.log("Peripheralの検索中")
            self.textProgress.selectable = true
            self.textProgress.text = "scanning peripherals..."
            self.textProgress.selectable = false
            BluetoothManager.sharedManager.startScan()
        })
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func didDisconnectPeripheral() {
        BluetoothManager.sharedManager.startScan()
    }
    
    func didFailToDiscoverService() {
        let alert: UIAlertController = UIAlertController(title: "検索に失敗", message: "Serviceが見つかりませんでした", preferredStyle:  UIAlertControllerStyle.Alert)
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
            Logger.log("Cancel")
            Logger.log("Peripheralの検索中")
            self.textProgress.selectable = true
            self.textProgress.text = "scanning peripherals..."
            self.textProgress.selectable = false
            BluetoothManager.sharedManager.startScan()
        })
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    func scanningCharacteristic() {
        textProgress.selectable = true
        textProgress.text = "scanning characteristics..."
        textProgress.selectable = false
    }
    
    func didFailToDiscoverCharacteristic() {
        let alert: UIAlertController = UIAlertController(title: "検索に失敗", message: "Characteristicが見つかりませんでした", preferredStyle:  UIAlertControllerStyle.Alert)
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
            Logger.log("Cancel")
            Logger.log("Peripheralの検索中")
            self.textProgress.selectable = true
            self.textProgress.text = "scanning peripherals..."
            self.textProgress.selectable = false
            BluetoothManager.sharedManager.startScan()
        })
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func completedConnection() {
        textProgress.selectable = true
        textProgress.text = "connection completed"
        textProgress.selectable = false
        navigateToMainViewController()
    }
}
