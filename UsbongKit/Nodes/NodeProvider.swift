//
//  NodeProvider.swift
//  NodeKit
//
//  Created by Chris Amanse on 12/27/15.
//  Copyright © 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import Foundation

/// `NodeProvider` protocol defines set of methods for providing nodes
public protocol NodeProvider {
    /// Current node
    var currentNode: Node? { get }
    
    /// Boolean value indicating whether a next node is available
    var nextNodeIsAvailable: Bool { get }
    
    /// Boolean value indicating whether a previous node is available
    var previousNodeIsAvailable: Bool { get }
    
    /// Transition to next node
    /// - returns: A Boolean value indicating whether a transition occurred
    func transitionToNextNode() -> Bool
    
    /// Transition to previous node
    /// - returns: A Boolean value indicating whether a transition occurred
    func transitionToPreviousNode() -> Bool
}

public extension NodeProvider {
    /// A Boolean value indicating whether the current node has nothing selected
    public var nothingSelected: Bool {
        if let selectionNode = currentNode as? SelectionTypeNode {
            return selectionNode.selectionModule.selectedIndices.count == 0
        }
        
        return true
    }
    
    /// A Boolean value indicating whether the node is a selection type
    public var currentNodeIsSelectionType: Bool {
        return currentNode is SelectionTypeNode
    }
}

/// A simple collection of nodes which conforms to `NodeProvider`
open class NodeCollection: NodeProvider {
    fileprivate var currentIndex: Int = 0
    open var nodes: [Node] = []
    
    public init(nodes: [Node]) {
        self.nodes = nodes
    }
    
    open var currentNode: Node? {
        if nodes.count > 0 {
            return nodes[currentIndex]
        }
        
        return nil
    }
    
    open var nextNodeIsAvailable: Bool {
        let maxIndex = nodes.count - 1
        return currentIndex < maxIndex
    }
    
    open var previousNodeIsAvailable: Bool {
        return currentIndex > 0
    }
    
    open func transitionToNextNode() -> Bool {
        if nextNodeIsAvailable {
            currentIndex += 1
            return true
        }
        
        return false
    }
    
    open func transitionToPreviousNode() -> Bool {
        if previousNodeIsAvailable {
            currentIndex -= 1
            return true
        }
        
        return false
    }
}
