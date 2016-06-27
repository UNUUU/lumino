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
    var uuid: String
    var peripheral: CBPeripheral
    var localName: String
    
    init(uuid: String, peripheral: CBPeripheral, localName: String) {
        self.uuid = uuid
        self.peripheral = peripheral
        self.localName = localName
    }
}
