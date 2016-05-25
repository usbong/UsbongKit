//
//  NodeProvider.swift
//  NodeKit
//
//  Created by Chris Amanse on 12/27/15.
//  Copyright © 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import Foundation

public protocol NodeProvider {
    var currentNode: Node? { get }
    var nextNodeIsAvailable: Bool { get }
    var previousNodeIsAvailable: Bool { get }
    
    func transitionToNextNode() -> Bool
    func transitionToPreviousNode() -> Bool
}

public extension NodeProvider {
    public var nothingSelected: Bool {
        if let selectionNode = currentNode as? SelectionTypeNode {
            return selectionNode.selectionModule.selectedIndices.count == 0
        }
        
        return true
    }
    
    public var currentNodeIsSelectionType: Bool {
        return currentNode is SelectionTypeNode
    }
}

public class NodeCollection {
    private var currentIndex: Int = 0
    public var nodes: [Node] = []
    
    public init(nodes: [Node]) {
        self.nodes = nodes
    }
}

extension NodeCollection: NodeProvider {
    public var currentNode: Node? {
        if nodes.count > 0 {
            return nodes[currentIndex]
        }
        
        return nil
    }
    
    public var nextNodeIsAvailable: Bool {
        let maxIndex = nodes.count - 1
        return currentIndex < maxIndex
    }
    
    public var previousNodeIsAvailable: Bool {
        return currentIndex > 0
    }
    
    public func transitionToNextNode() -> Bool {
        if nextNodeIsAvailable {
            currentIndex += 1
            return true
        }
        
        return false
    }
    
    public func transitionToPreviousNode() -> Bool {
        if previousNodeIsAvailable {
            currentIndex -= 1
            return true
        }
        
        return false
    }
}
