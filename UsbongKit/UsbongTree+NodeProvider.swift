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
    
    public func saveStateOfLastNode() {
        let state = UsbongNodeState(transitionName: currentTargetTransitionName, node: currentNode, type: currentTaskNodeType)
        usbongNodeStates.append(state)
    }
    
    public func transitionToNextNode() -> Bool {
        let transitionName = currentTargetTransitionName
        guard let nextTaskNodeName = currentTransitionInfo[transitionName] else {
            return false
        }
        
        // Create UsbongNodeState (before generating a new node)
        let state = UsbongNodeState(transitionName: transitionName, node: currentNode, type: currentTaskNodeType)
        
        // Make current node to next task node
        currentNode = nodeWithName(nextTaskNodeName)
        
        // Append task node name to array
        taskNodeNames.append(nextTaskNodeName)
        
        // Append state to array
        usbongNodeStates.append(state)
        
        // Debug output
//        print(generateOutput(UsbongAnswersGeneratorDefaultCSVString))
        
        return true
    }
    public func transitionToPreviousNode() -> Bool {
        if previousNodeIsAvailable {
            // Remove last state from array
            usbongNodeStates.removeLast()
            
            // Remove last task node name from array
            taskNodeNames.removeLast()
            
            // Reload current task node based on taskNodeNames array
            reloadCurrentTaskNode()
            
            return true
        }
        
        return false
    }
}
