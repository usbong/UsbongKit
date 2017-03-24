//
//  SelectionTypeNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

/// Node that supports selection (contains a `SelectionTypeModule`)
public protocol SelectionTypeNode {
    /// The selection type module
    var selectionModule: SelectionTypeModule { get }
}