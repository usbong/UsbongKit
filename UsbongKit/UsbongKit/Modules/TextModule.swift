//
//  TextModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Display text
open class TextModule: Module {
    open var text: String = ""
    
    public init(text: String) {
        self.text = text
    }
}
