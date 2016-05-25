//
//  DateModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Display a date
public class DateModule: Module {
    public var date: NSDate
    
    public init(date: NSDate = NSDate()) {
        self.date = date
    }
}
