//
//  TextInputModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

/// A type of input
public enum TextInputModuleType {
    case singleLine
    case singleLineNumerical
    case multipleLine
}

/// Display text input
open class TextInputModule: Module {
    open var textInput: String
    open var type: TextInputModuleType
    
    /// Create `TextInputModule` with specified type
    public init(textInput: String, type: TextInputModuleType = .singleLine) {
        self.textInput = textInput
        self.type = type
    }
    
    /// Create `TextInputModule` with empty text and specified type
    public convenience init(type: TextInputModuleType) {
        self.init(textInput: "", type: type)
    }
    
    /// Create `TextInputModule` with empty text and `.SingleLine` type
    public convenience init() {
        self.init(textInput: "")
    }
}
