//
//  CheckboxesModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Display checkboxes
open class CheckboxesModule: ListModule, SelectionTypeModule {
    public init(options: [String], selectedIndices: [Int] = []) {
        super.init(options: options)
        self.selectedIndices = selectedIndices
    }
    
    // MARK: Selection type module
    open fileprivate(set) var selectedIndices: [Int] = []
    
    open func selectIndex(_ index: Int) {
        if !selectedIndices.contains(index) {
            selectedIndices.append(index)
        }
    }
    open func deselectIndex(_ index: Int) {
        while let indexOfIndex = selectedIndices.index(of: index) {
            selectedIndices.remove(at: indexOfIndex)
        }
    }
    open func toggleIndex(_ index: Int) {
        if selectedIndices.contains(index) {
            deselectIndex(index)
        } else {
            selectedIndices.append(index)
        }
    }
}
