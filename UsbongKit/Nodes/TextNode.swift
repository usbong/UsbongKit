//
//  TextNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays text
public class TextNode: Node {
    public init(text: String) {
        super.init(modules: [TextModule(text: text)])
    }
}
