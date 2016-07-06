//
//  DateUtility.swift
//  lumino
//
//  Created by takumi.kashima on 7/7/16.
//  Copyright © 2016 UNUUU. All rights reserved.
//

class DateUtility {
    class func now(format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(NSDate())
    }
}
