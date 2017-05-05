//
//  UsbongNodeState.swift
//  UsbongKit
//
//  Created by Joe Amanse on 12/03/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

public struct UsbongNodeState {
    public var transitionName: String
    internal var taskNodeType: TaskNodeType?
    public var fields: [String: AnyObject] = [:]
    
    public init(transitionName: String) {
        self.transitionName = transitionName
    }
    
    internal init(transitionName: String, node: Node?, type: TaskNodeType?) {
        self.init(transitionName: transitionName)
        taskNodeType = type
        
        // Add fields based on node
        if let node = node as? SelectionTypeNode {
            fields["selectedIndices"] = node.selectionModule.selectedIndices as AnyObject?
        }
        if let node = node as? TextInputTypeNode {
            fields["textInput"] = node.textInput as AnyObject?
        }
        
        if let dateNode = node as? DateNode {
            fields["date"] = dateNode.date as AnyObject?
        }
    }
}
