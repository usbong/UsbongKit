//
//  UsbongTree.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/27/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation
import SWXMLHash

public class UsbongTree {
    public let treeRootURL: NSURL
    
    public let title: String
    public let baseLanguage: String
    public let currentLanguage: String
    public let availableLanguages: [String]
    
    internal private(set) var taskNodeNames: [String] = []
    
    internal private(set) var transitionInfo: [String: String] = [:]
    internal let languageXMLURLs: [NSURL]
    internal let hintsXMLURLs: [NSURL]
    
    private let treeXMLIndexer: XMLIndexer
    
    private var processDefinitionIndexer: XMLIndexer {
        return treeXMLIndexer[XMLIdentifier.processDefinition]
    }
    
    public private(set) var currentNode: Node?
    
    public init(treeRootURL: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        
        self.treeRootURL = treeRootURL
        
        // Fetch main XML URL
        let fileName = treeRootURL.URLByDeletingPathExtension?.lastPathComponent ?? ""
        let XMLURL = treeRootURL.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("xml")
        let XMLData = NSData(contentsOfURL: XMLURL) ?? NSData()
        
        // Set title, if blank, set to "Untitled"
        let title: String
        if fileName.stringByReplacingOccurrencesOfString(" ", withString: "").characters.count == 0 {
            title = "Untitled"
        } else {
            title = fileName
        }
        self.title = title
        
        // Set property
        treeXMLIndexer = SWXMLHash.parse(XMLData)
        
        // Set base and current language
        let processDefinitionIndexer = treeXMLIndexer[XMLIdentifier.processDefinition]
        baseLanguage = processDefinitionIndexer.element?.attributes[XMLIdentifier.lang] ?? "Unknown"
        currentLanguage = baseLanguage
        
        // Fetch URLs for language XMLs
        let transURL = treeRootURL.URLByAppendingPathComponent("trans", isDirectory: true)
        self.languageXMLURLs = (try? fileManager.contentsOfDirectoryAtURL(transURL,
                includingPropertiesForKeys: nil, options: .SkipsSubdirectoryDescendants)) ?? []
        
        // Set available languages and also include base language
        var availableLanguages: [String] = []
        languageXMLURLs.forEach { url in
            let language = url.URLByDeletingPathExtension?.lastPathComponent ?? "Unknown"
            availableLanguages.append(language)
        }
        
        if !availableLanguages.contains(baseLanguage) {
            availableLanguages.append(baseLanguage)
        }
        availableLanguages.sortInPlace()
        
        self.availableLanguages = availableLanguages
        
        // Fetch URLs for hints XMLs
        let hintsURL = treeRootURL.URLByAppendingPathComponent("hints", isDirectory: true)
        self.hintsXMLURLs = (try? fileManager.contentsOfDirectoryAtURL(hintsURL,
                includingPropertiesForKeys: nil, options: .SkipsSubdirectoryDescendants)) ?? []
        
        
        // Fetch starting task node
        if let element = processDefinitionIndexer[XMLIdentifier.startState][XMLIdentifier.transition].element {
            if let startName = element.attributes[XMLIdentifier.to] {
                taskNodeNames.append(startName)
                currentNode = nodeWithName(startName)
            }
        }
    }
    
    private func nodeWithName(taskNodeName: String) -> Node? {
        var node: Node? = nil
        if let (indexer, type) = nodeIndexerWithName(taskNodeName) {
            switch type {
            case .TaskNode, .Decision:
                let nameInfo = XMLNameInfo(name: taskNodeName, language: currentLanguage, treeRootURL: treeRootURL)
                print(nameInfo.type)
                
                guard let taskNodeType = nameInfo.type else {
                    break
                }
                
                switch taskNodeType {
                case .TextDisplay:
                    let text = nameInfo.text
                    node = TextNode(text: text)
                default:
                    node = TextNode(text: "Unknown Node")
                }
            case .EndState:
                node = TextNode(text: "You've now reached the end")
            }
        }
        
        return node
    }
    
    // MARK: Get XML Indexer of task nodes
    private func taskNodeIndexerWithName(name: String) -> XMLIndexer? {
        return try? processDefinitionIndexer[XMLIdentifier.taskNode].withAttr(XMLIdentifier.name, name)
    }
    private func endStateIndexerWithName(name: String) -> XMLIndexer? {
        return try? processDefinitionIndexer[XMLIdentifier.endState].withAttr(XMLIdentifier.name, name)
    }
    private func decisionIndexerWithName(name: String) -> XMLIndexer? {
        return try? processDefinitionIndexer[XMLIdentifier.decision].withAttr(XMLIdentifier.name, name)
    }
    private func nodeIndexerWithName(name: String) -> (indexer: XMLIndexer, type: NodeType)? {
        var indexer: XMLIndexer?
        var type = NodeType.TaskNode
        
        // Find task node
        indexer = taskNodeIndexerWithName(name)
        
        // Find end state, if task node not found
        if indexer == nil {
            indexer = endStateIndexerWithName(name)
            type = .EndState
        }
        
        // Find decision if end state not found
        if indexer == nil {
            indexer = decisionIndexerWithName(name)
            type = .Decision
        }
        
        if let nodeIndexer = indexer {
            return (nodeIndexer, type)
        } else {
            return nil
        }
    }
}

// MARK: - NodeType
internal enum NodeType {
    case TaskNode
    case EndState
    case Decision
}
