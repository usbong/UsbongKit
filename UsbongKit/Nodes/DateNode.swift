//
//  DateNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays a date picker with text on top
open class DateNode: Node {
    public init(text: String, date: Date = Date()) {
        
        super.init(modules: [
            TextModule(text: text),
            DateModule(date: date)
            ])
    }
    
    open var date: Date {
        get {
            return (modules[1] as! DateModule).date as Date
        }
        set {
            (modules[1] as! DateModule).date = newValue
        }
    }
}
