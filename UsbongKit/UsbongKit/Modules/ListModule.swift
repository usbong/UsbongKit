//
//  ListModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Display a list
open class ListModule: OptionsTypeModule {
    open var options: [String] = []
    
    public init(options: [String]) {
        self.options = options
    }
}
