//
//  ChecklistNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Displays a checklist with text on top
public class ChecklistNode: Node {
    public init(text: String, options: [String], selectedIndices: [Int] = []) {
        super.init(modules: [
            TextModule(text: text),
            CheckboxesModule(options: options, selectedIndices: selectedIndices)
            ])
    }
}

extension ChecklistNode: SelectionTypeNode {
    public var selectionModule: SelectionTypeModule {
        return modules[1] as! SelectionTypeModule
    }
}
