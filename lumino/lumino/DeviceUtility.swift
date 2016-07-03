//
//  DeviceUtility.swift
//  lumino
//
//  Created by takumi.kashima on 7/4/16.
//  Copyright © 2016 UNUUU. All rights reserved.
//

import SwiftKeychainWrapper

class DeviceUtility {
    private static let KEY_UUID = "UUID"
    
    class var UUIDString: String {
        get {
            var uuidString: String? = nil
            let ud = NSUserDefaults.standardUserDefaults()
            if (ud.objectForKey(KEY_UUID) != nil) {
                // UserDefaultから取得する
                uuidString = ud.objectForKey(KEY_UUID) as! String!
            } else {
                // Keychainから取得する
                uuidString = KeychainWrapper.stringForKey(KEY_UUID)
            }
            
            if (uuidString == nil) {
                uuidString = UIDevice.currentDevice().identifierForVendor!.UUIDString
                KeychainWrapper.setString(uuidString!, forKey: KEY_UUID)
            }
            ud.setObject(uuidString, forKey: KEY_UUID)
            ud.synchronize()
            
            print("UUID: \(uuidString!)")
            return uuidString!
        }
    }
}
