//
//  RadioButtonsModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Display radiobuttons
public class RadioButtonsModule: ListModule, SelectionTypeModule {
    public var selectedIndex: Int? = nil
    
    public init(options: [String], selectedIndex: Int? = nil) {
        super.init(options: options)
        self.selectedIndex = selectedIndex
    }
    
    // MARK: Selection type module
    public var selectedIndices: [Int] {
        if let index = selectedIndex {
            return [index]
        }
        return []
    }
    
    public func selectIndex(index: Int) {
        selectedIndex = index
    }
    public func deselectIndex(index: Int) {
        if selectedIndex == index {
            selectedIndex = nil
        }
    }
    public func toggleIndex(index: Int) {
        if selectedIndex == index {
            selectedIndex = nil
        } else {
            selectedIndex = index
        }
    }
}
