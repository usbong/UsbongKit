//
//  UsbongTree+NodeProvider.swift
//  UsbongKit
//
//  Created by Chris Amanse on 1/1/16.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

extension UsbongTree: NodeProvider {
    public var nextNodeIsAvailable: Bool {
        guard let name = nextTaskNodeName else {
            return false
        }
        
        return nodeIndexerAndTypeWithName(name) != nil
    }
    public var previousNodeIsAvailable: Bool {
        return taskNodeNames.count > 1
    }
    
    public func transitionToNextNode() -> Bool {
        guard let name = nextTaskNodeName else {
            return false
        }
        
        guard let node = nodeWithName(name) else {
            return false
        }
        
        currentNode = node
        taskNodeNames.append(name)
        
        return true
    }
    public func transitionToPreviousNode() -> Bool {
        if previousNodeIsAvailable {
            taskNodeNames.removeLast()
            reloadCurrentTaskNode()
            
            return true
        }
        
        return false
    }
}
