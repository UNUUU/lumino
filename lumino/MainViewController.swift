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

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, OnBluetoothInteractionListener {
    private var messageList: [MessageEntity] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onTouchDeviceId(sender: AnyObject) {
        let alert: UIAlertController = UIAlertController(title: nil, message: DeviceUtility.UUIDString, preferredStyle:  UIAlertControllerStyle.Alert)
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func loadMessageList() {
        let path = NSBundle.mainBundle().pathForResource("message", ofType: "json")!
        let jsonData = NSData(contentsOfFile: path)!
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as! NSDictionary
            for key in json.allKeys {
                let writeString = json.objectForKey(key)
                messageList.append(MessageEntity(name: key as! String, writeString: writeString as! String))
            }
        } catch let err as NSError {
            print(err.localizedDescription)
        }
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        BluetoothManager.sharedManager.listener = self
        
        loadMessageList()
        
        // 接続時に現在日時を書き込む
        writeMessage("T\(DateUtility.now("HHmmssddMMyyyy"))")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.onReceiveMessage), name: "onReceiveMessage", object: nil)
    }
    
    func onReceiveMessage(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let message = userInfo["message"]! as! String
        print("received message: \(message)")
        writeMessage(message)
    }
    
    private func writeMessage(message: String) {
        if (BluetoothManager.sharedManager.peripheral != nil
            && BluetoothManager.sharedManager.characteristic != nil) {
            print("wrote message \(message)")
            let data = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:true)
            BluetoothManager.sharedManager.peripheral!.writeValue(data!, forCharacteristic: BluetoothManager.sharedManager.characteristic!, type: CBCharacteristicWriteType.WithoutResponse)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MessageCell")
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.font = UIFont(name: "Dosis-Light", size: 28)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.text = messageList[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        writeMessage(messageList[indexPath.row].writeString)
    }
    
    func didDisconnectPeripheral() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func scanningPeripheral() {
        
    }
    
    func connectingPeripheral() {
        
    }
    
    func scanningService() {
        
    }
    
    func didFailToConnectPeripheral() {
        
    }
    
    func didFailToDiscoverService() {
        
    }
    
    func scanningCharacteristic() {
        
    }
    
    func didFailToDiscoverCharacteristic() {
        
    }
    
    func completedConnection() {
        
    }
}

