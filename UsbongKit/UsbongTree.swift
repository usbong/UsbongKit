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
    public var currentLanguage: String {
        didSet {
            reloadCurrentTaskNode()
        }
    }
    public var currentLanguageCode: String {
        return UsbongLanguage(language: currentLanguage).languageCode
    }
    public let availableLanguages: [String]
    
    public private(set) var backgroundImageURL: NSURL?
    public private(set) var backgroundAudioURL: NSURL?
    public private(set) var currentVoiceOverAudioURL: NSURL?
    
    internal var taskNodeNames: [String] = []
    
    internal private(set) var checklistTargetNumberOfTicks = 0
    internal private(set) var currentTransitionInfo: [String: String] = [:]
    internal var currentTargetTransitionName: String {
        get {
            // If current task node type is radio buttons, ignore selected module (transition to any)
            switch currentNode {
            case let checklistNode as ChecklistNode:
                if checklistNode.selectionModule.selectedIndices.count == checklistTargetNumberOfTicks {
                    return "Yes"
                } else {
                    return "No"
                }
            default:
                return "Any"
            }
//            if let node = currentNode as? RadioButtonsNode {
//                switch node {
//                case let linkNode as RadioButtonsNode:
//                    if let linkModule = linkTaskNode.currentSelectedModule {
//                        return linkModule.taskIdentifier
//                    }
//                case let checkListTaskNode as CheckListTaskNode:
//                    if checkListTaskNode.reachedTarget {
//                        return "Yes"
//                    } else {
//                        return "No"
//                    }
//                default:
//                    break
//                }
//            }
        }
    }
    internal var nextTaskNodeName: String? {
        return currentTransitionInfo[currentTargetTransitionName]
    }
    
    internal let languageXMLURLs: [NSURL]
    internal let hintsXMLURLs: [NSURL]
    
    private let treeXMLIndexer: XMLIndexer
    
    private var processDefinitionIndexer: XMLIndexer {
        return treeXMLIndexer[XMLIdentifier.processDefinition]
    }
    
    public var currentNode: Node?
    
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
    
    internal func reloadCurrentTaskNode() {
        if let currentTaskNodeName = taskNodeNames.last {
            currentNode = nodeWithName(currentTaskNodeName)
        }
    }
    
    internal func nodeWithName(taskNodeName: String) -> Node? {
        var node: Node? = nil
        if let (indexer, type) = nodeIndexerAndTypeWithName(taskNodeName) {
            switch type {
            case .TaskNode, .Decision:
                let nameInfo = XMLNameInfo(name: taskNodeName, language: currentLanguage, treeRootURL: treeRootURL)
                
                // Get urls for assets
                backgroundAudioURL = nameInfo.backgroundAudioURL
                backgroundImageURL = nameInfo.backgroundImageURL
                currentVoiceOverAudioURL = nameInfo.audioURL
                
                print(nameInfo.type)
                guard let taskNodeType = nameInfo.type else {
                    break
                }
                
                let finalText = translateText(nameInfo.text)
                switch taskNodeType {
                case .TextDisplay:
                    node = TextNode(text: finalText)
                default:
                    node = TextNode(text: "Unknown Node")
                }
                
                // Fetch transition info
                currentTransitionInfo = transitionInfoFromTransitionIndexers(indexer[XMLIdentifier.transition].all, andTaskNodeType: taskNodeType)
            case .EndState:
                node = TextNode(text: "You've now reached the end")
            }
        }
        
        return node
    }
    
    // MARK: Get transition info from transition elements
    private func transitionInfoFromTransitionIndexers(transitionIndexers: [XMLIndexer], andTaskNodeType type: TaskNodeType) -> [String: String]{
        var transitionInfo: [String: String] = [:]
        
        for indexer in transitionIndexers {
            guard let attributes = indexer.element?.attributes else {
                continue
            }
            
            // Get value of name
            let name = attributes[XMLIdentifier.name] ?? "Any"
            
            // Get value of to
            var to = attributes[XMLIdentifier.to] ?? ""
            
            // Remove identifier for link transition
            if type == .Link {
                var components = to.componentsSeparatedByString("~")
                components.removeLast()
                to = components.joinWithSeparator("~")
            }
            
            transitionInfo[name] = to
        }
        
        return transitionInfo
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
    internal func nodeIndexerAndTypeWithName(name: String) -> (indexer: XMLIndexer, type: NodeType)? {
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
    
    // MARK: Language
    
    private var currentLanguageXMLURL: NSURL? {
        for url in languageXMLURLs {
            // Check if file name is equal to language
            let name = url.URLByDeletingPathExtension?.lastPathComponent ?? "Unknown"
            if currentLanguage == name {
                return url
            }
        }
        return nil
    }
    
    private func translateText(text: String) -> String {
        var translatedText = text
        
        // Fetch translation from XML
        if let languageXMLURL = currentLanguageXMLURL {
            let languageXML = SWXMLHash.parse(NSData(contentsOfURL: languageXMLURL) ?? NSData())
            let resources = languageXML[XMLIdentifier.resources]
            
            if let stringElement = try? resources[XMLIdentifier.string].withAttr(XMLIdentifier.name, text) {
                translatedText = stringElement.element?.text ?? text
            }
        }
        
        return translatedText
    }
}

// MARK: - NodeType
internal enum NodeType {
    case TaskNode
    case EndState
    case Decision
}
