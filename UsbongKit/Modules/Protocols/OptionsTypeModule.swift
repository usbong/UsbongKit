//
//  OptionsTypeModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

/// Protocol for list type module
public protocol OptionsTypeModule: Module {
    var options: [String] { get set }
}
