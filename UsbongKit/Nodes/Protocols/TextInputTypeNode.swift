//
//  TextInputTypeNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

/// Node the supports text input
public protocol TextInputTypeNode: class {
    /// The current text input
    var textInput: String { get set }
}
