//
//  PeripheralEntity.swift
//  lumino
//
//  Created by takumi.kashima on 2016/06/27.
//  Copyright © 2016年 UNUUU. All rights reserved.
//

import Foundation
import CoreBluetooth

class PeripheralEntity {
    let peripheral: CBPeripheral
    let localName: String?
    
    init(peripheral: CBPeripheral, localName: String?) {
        self.peripheral = peripheral
        self.localName = localName
    }
}
