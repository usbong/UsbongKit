//
//  Node.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

// MARK: - Nodes

/// Nodes are collections of modules. Subclass `Node` to provide common combinations of modules.
/// 
/// **Note**: Order of modules determines the order of which they are displayed
public class Node {
    /// Modules of the node
    public let modules: [Module]
    
    /// Create a node with a set of modules
    public init(modules: [Module]) {
        self.modules = modules
    }
}
