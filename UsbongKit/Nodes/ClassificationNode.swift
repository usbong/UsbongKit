//
//  ClassificationNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays a list with text on top
open class ClassificationNode: Node {
    public init(text: String, list: [String]) {
        super.init(modules: [
            TextModule(text: text),
            ListModule(options: list)
            ])
    }
}
