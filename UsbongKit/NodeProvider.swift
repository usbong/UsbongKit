//
//  NodeProvider.swift
//  NodeKit
//
//  Created by Chris Amanse on 12/27/15.
//  Copyright © 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import Foundation

public protocol NodeProvider {
    var currentNode: Node { get }
    var nextNodeIsAvailable: Bool { get }
    var previousNodeIsAvailable: Bool { get }
    var nothingSelected: Bool { get }
}

//public extension NodeProvider {
//    public var nothingSelected: Bool {
//    }
//}