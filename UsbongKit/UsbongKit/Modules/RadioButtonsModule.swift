//
//  RadioButtonsModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Display radiobuttons
open class RadioButtonsModule: ListModule, SelectionTypeModule {
    open var selectedIndex: Int? = nil
    
    public init(options: [String], selectedIndex: Int? = nil) {
        super.init(options: options)
        self.selectedIndex = selectedIndex
    }
    
    // MARK: Selection type module
    open var selectedIndices: [Int] {
        if let index = selectedIndex {
            return [index]
        }
        return []
    }
    
    open func selectIndex(_ index: Int) {
        selectedIndex = index
    }
    open func deselectIndex(_ index: Int) {
        if selectedIndex == index {
            selectedIndex = nil
        }
    }
    open func toggleIndex(_ index: Int) {
        if selectedIndex == index {
            selectedIndex = nil
        } else {
            selectedIndex = index
        }
    }
}
