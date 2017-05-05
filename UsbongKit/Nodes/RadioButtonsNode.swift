//
//  RadioButtonsNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays a radio button selection with text on top
open class RadioButtonsNode: Node {
    public init(text: String, options: [String], selectedIndex: Int? = nil) {
        super.init(modules: [
            TextModule(text: text),
            RadioButtonsModule(options: options, selectedIndex: selectedIndex)
            ])
    }
}

extension RadioButtonsNode: SelectionTypeNode {
    public var selectionModule: SelectionTypeModule {
        return modules[1] as! SelectionTypeModule
    }
}
