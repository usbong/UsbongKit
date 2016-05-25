//
//  CheckboxesModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Display checkboxes
public class CheckboxesModule: ListModule, SelectionTypeModule {
    public init(options: [String], selectedIndices: [Int] = []) {
        super.init(options: options)
        self.selectedIndices = selectedIndices
    }
    
    // MARK: Selection type module
    public private(set) var selectedIndices: [Int] = []
    
    public func selectIndex(index: Int) {
        if !selectedIndices.contains(index) {
            selectedIndices.append(index)
        }
    }
    public func deselectIndex(index: Int) {
        while let indexOfIndex = selectedIndices.indexOf(index) {
            selectedIndices.removeAtIndex(indexOfIndex)
        }
    }
    public func toggleIndex(index: Int) {
        if selectedIndices.contains(index) {
            deselectIndex(index)
        } else {
            selectedIndices.append(index)
        }
    }
}
