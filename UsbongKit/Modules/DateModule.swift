//
//  DateModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Display a date
open class DateModule: Module {
    open var date: Date
    
    public init(date: Date = Date()) {
        self.date = date
    }
}
