//
//  SelectionTypeModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

/// Protocol for selection type
public protocol SelectionTypeModule: Module {
    var selectedIndices: [Int] { get }
    func selectIndex(_ index: Int)
    func deselectIndex(_ index: Int)
    func toggleIndex(_ index: Int)
}
