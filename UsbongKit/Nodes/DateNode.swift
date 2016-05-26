//
//  DateNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays a date picker with text on top
public class DateNode: Node {
    public init(text: String, date: NSDate = NSDate()) {
        
        super.init(modules: [
            TextModule(text: text),
            DateModule(date: date)
            ])
    }
    
    public var date: NSDate {
        get {
            return (modules[1] as! DateModule).date
        }
        set {
            (modules[1] as! DateModule).date = newValue
        }
    }
}
