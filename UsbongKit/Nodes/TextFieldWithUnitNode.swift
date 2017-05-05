//
//  TextFieldWithUnitNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Similar to `TextFieldNumericalNode`, but adds a unit indicator at the bottom
open class TextFieldWithUnitNode: Node, TextInputTypeNode {
    public init(text: String, textInput: String = "", unit: String) {
        super.init(modules: [
            TextModule(text: text),
            TextInputModule(textInput: textInput, type: .singleLineNumerical),
            TextModule(text: unit)
            ])
    }
    
    open var textInput: String {
        get {
            return (modules[1] as! TextInputModule).textInput
        }
        set {
            (modules[1] as! TextInputModule).textInput = newValue
        }
    }
}
