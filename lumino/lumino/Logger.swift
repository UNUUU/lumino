//
//  Logger.swift
//  lumino
//
//  Created by takumi.kashima on 2016/07/02.
//

import Foundation
import Antenna

class Logger {
    class func log(message: String, function: String = #function, file: String = #file, line: Int = #line) {
        var filename = file
        if let match = filename.rangeOfString("[^/]*$", options: .RegularExpressionSearch) {
            filename = filename.substringWithRange(match)
        }
        print("Log:\(filename):L\(line):\(function) \"\(message)\"")
       Antenna.sharedLogger().log("lumino: \(filename):L\(line):\(function) \"\(message)\"")
    }
}