//
//  TextFieldNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays a text field with text on top
open class TextFieldNode: Node, TextInputTypeNode {
    public init(text: String, textInput: String = "") {
        super.init(modules: [
            TextModule(text: text),
            TextInputModule(textInput: textInput)
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
