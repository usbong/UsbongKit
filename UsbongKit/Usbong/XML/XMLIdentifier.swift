//
//  XMLIdentifier.swift
//  UsbongKit
//
//  Created by Chris Amanse on 26/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

/// XML identifiers for tags
internal struct XMLIdentifier {
    static let processDefinition = "process-definition"
    static let startState = "start-state"
    static let endState = "end-state"
    static let taskNode = "task-node"
    static let decision = "decision"
    static let transition = "transition"
    static let task = "task"
    static let to = "to"
    static let name = "name"
    
    static let resources = "resources"
    static let string = "string"
    static let lang = "lang"
}
