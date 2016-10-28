//
//  UsbongTree.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/27/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation
import SWXMLHash

/// An `UsbongTree` object parses utree files, and tracks its current location and states.
public class UsbongTree {
    /// The URL for the .utree folder inside the unpacked tree
    public let treeRootURL: NSURL
    
    /// Title derived from the folder
    public let title: String
    
    /// Base language of the utree. Default is "English"
    public let baseLanguage: String
    
    /// Current set language of utree
    public var currentLanguage: String {
        didSet {
            reloadCurrentTaskNode()
            loadHintsDictionary()
        }
    }
    
    /// The language code for the current language
    public var currentLanguageCode: String {
        return UsbongLanguage(language: currentLanguage).languageCode
    }
    
    /// Available languages of the utree
    public let availableLanguages: [String]
    
    /// Current background image URL
    public private(set) var backgroundImageURL: NSURL?
    
    /// Current background audio URL
    public private(set) var backgroundAudioURL: NSURL?
    
    /// Current voice-over audio URL
    public private(set) var currentVoiceOverAudioURL: NSURL?
    
    /// A collection of task node names from start to current
    internal var taskNodeNames: [String] = []
    
    /// The target number of ticks for a checklist
    internal private(set) var checklistTargetNumberOfTicks = 0
    
    /// The current transition info
    internal private(set) var currentTransitionInfo: [String: String] = [:]
    
    /// Usbong node states. This is for generating the answers
    internal var usbongNodeStates: [UsbongNodeState] = []
    
    /// Current target transition name based on the state of the current task node
    internal var currentTargetTransitionName: String {
        get {
            // If current task node type is radio buttons, ignore selected module (transition to any)
            switch currentNode {
            case let checklistNode as ChecklistNode:
                if checklistNode.selectionModule.selectedIndices.count >= checklistTargetNumberOfTicks {
                    return "Yes"
                } else {
                    return "No"
                }
            case let radioButtonsNode as RadioButtonsNode:
                if let taskNodeType = currentTaskNodeType {
                    switch taskNodeType {
                    case .Link, .RadioButtonsWithAnswer:
                        guard let module = radioButtonsNode.selectionModule as? RadioButtonsModule else {
                            break
                        }
                        guard let selectedIndex = module.selectedIndex else {
                            break
                        }
                        
                        switch taskNodeType {
                        case .Link:
                            return module.options[selectedIndex]
                        case .RadioButtonsWithAnswer:
                            if selectedIndex == currentTargetSelectedIndex {
                                return "Yes"
                            } else {
                                return "No"
                            }
                        default:
                            return "Any"
                        }
                    default:
                        break
                    }
                }
                return "Any"
            case let textInputTypeNode as TextInputTypeNode:
                guard let taskNodeType = currentTaskNodeType else {
                    return "Any"
                }
                
                switch taskNodeType {
                case .TextFieldWithAnswer, .TextAreaWithAnswer:
                    // Return Yes or No if with answer
                    if let answers = currentTargetTextInput where answers.componentsSeparatedByString("|").contains(textInputTypeNode.textInput) {
                        return "Yes"
                    } else {
                        return "No"
                    }
                default:
                    // If doesn't have answer, return any
                    return "Any"
                }
            default:
                return "Any"
            }
        }
    }
    
    /// Current text input if any
    internal var currentTextInput: String? {
        get {
            switch currentNode {
            case let textInputTypeNode as TextInputTypeNode:
                return textInputTypeNode.textInput
            default:
                return nil
            }
        }
    }
    
    /// Current target text input (for nodes with current answers)
    internal var currentTargetTextInput: String?
    
    /// Current target selection (for selection nodes with answers)
    internal var currentTargetSelectedIndex: Int?
    
    /// The next task node name
    internal var nextTaskNodeName: String? {
        return currentTransitionInfo[currentTargetTransitionName]
    }
    
    /// URLs for language XML files
    internal let languageXMLURLs: [NSURL]
    
    /// URLs for hints XML files
    internal let hintsXMLURLs: [NSURL]
    
    /// Dictionary for hints
    public private(set) var hintsDictionary: [String: String] = [:]
    
    /// XMLIndexer for tree
    private let treeXMLIndexer: XMLIndexer
    
    /// XMLIndexer for "process-definition"
    private var processDefinitionIndexer: XMLIndexer {
        return treeXMLIndexer[XMLIdentifier.processDefinition]
    }
    
    // Current node is stored so that it isn't computed/fetched everytime it's being accessed
    /// The current node
    public internal(set) var currentNode: Node?
    
    /**
     Creates an instance of `UsbongTree`
     
     - parameter treeRootURL: The URL for the .utree folder inside the unpacked tree
    */
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
        baseLanguage = processDefinitionIndexer.element?.attributes[XMLIdentifier.lang] ?? Defaults.BaseLanguage
        currentLanguage = baseLanguage
        
        // Fetch URLs for language XMLs
        let transURL = treeRootURL.URLByAppendingPathComponent("trans", isDirectory: true)
        var languageXMLURLs = (try? fileManager.contentsOfDirectoryAtURL(transURL,
                includingPropertiesForKeys: nil, options: .SkipsSubdirectoryDescendants)) ?? []
        
        // Filter URLs - allow only .xml files
        languageXMLURLs = languageXMLURLs.filter { $0.pathExtension?.caseInsensitiveCompare("xml") == .OrderedSame }
        
        self.languageXMLURLs = languageXMLURLs
        
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
        hintsXMLURLs = (try? fileManager.contentsOfDirectoryAtURL(hintsURL,
                includingPropertiesForKeys: nil, options: .SkipsSubdirectoryDescendants)) ?? []
        loadHintsDictionary()
        
        // Fetch starting task node
        if let element = processDefinitionIndexer[XMLIdentifier.startState][XMLIdentifier.transition].element {
            if let startName = element.attributes[XMLIdentifier.to] {
                taskNodeNames.append(startName)
                currentNode = nodeWithName(startName)
            }
        }
    }
    
    /// Reloads or refetchs the current task node
    internal func reloadCurrentTaskNode() {
        if let currentTaskNodeName = taskNodeNames.last {
            currentNode = nodeWithName(currentTaskNodeName)
        }
    }
    
    /// The current `TaskNodeType`
    internal var currentTaskNodeType: TaskNodeType?
    
    /**
     Creates a node based on the task node name
     
     - parameter taskNodeName: The task node name
     
     - returns: The created `Node` object
    */
    internal func nodeWithName(taskNodeName: String) -> Node {
        var node: Node = TextNode(text: "Unknown Node")
        guard let (nodeIndexer, type) = nodeIndexerAndTypeWithName(taskNodeName) else {
            return node
        }
        
        let nameInfo = XMLNameInfo(name: taskNodeName, language: currentLanguage, treeRootURL: treeRootURL)
        
        // Get urls for assets
        backgroundAudioURL = nameInfo.backgroundAudioURL
        backgroundImageURL = nameInfo.backgroundImageURL
        currentVoiceOverAudioURL = nameInfo.audioURL
        
        switch type {
        case .TaskNode, .Decision:
            guard var taskNodeType = nameInfo.type else {
                break
            }
            if type == .Decision {
                taskNodeType = .Link // Decision type is same as link
            }
            currentTaskNodeType = taskNodeType
            
            var fetchedTransitionInfo: [String: String] = [:]
            let finalText = parseText(translateText(nameInfo.text))
            switch taskNodeType {
            case .TextDisplay:
                node = TextNode(text: finalText)
            case .ImageDisplay:
                node = ImageNode(image: nameInfo.image)
            case .TextImageDisplay:
                node = TextImageNode(text: finalText, image: nameInfo.image)
            case .ImageTextDisplay:
                node = ImageTextNode(image: nameInfo.image, text: finalText)
            case .Link where type == .Decision:
                var tasks: [String] = []
                
                let transitionIndexers = nodeIndexer[XMLIdentifier.transition].all
                
                // Fetch transition info (which are the same as tasks)
                for indexer in transitionIndexers {
                    guard let attributes = indexer.element?.attributes else { continue }
                    
                    // Get value of name
                    let name = attributes[XMLIdentifier.name] ?? "Any"
                    
                    // Get value of to
                    let to = attributes[XMLIdentifier.to] ?? ""
                    
                    tasks.append(name)
                    
                    fetchedTransitionInfo[name] = to
                }
                
                node = RadioButtonsNode(text: finalText, options: tasks)
            case .Link, .RadioButtons, .Checklist, .Classification, .RadioButtonsWithAnswer:
                var tasks: [String] = []
                
                // Fetch tasks (and transition info from task elements if link)
                let taskIndexers = nodeIndexer[XMLIdentifier.task].all
                taskIndexers.forEach({ taskIndexer in
                    guard let name = taskIndexer.element?.attributes[XMLIdentifier.name] else {
                        return
                    }
                    var nameComponents = name.componentsSeparatedByString("~")
                    let key = nameComponents.removeLast()
                    
                    let value = nameComponents.joinWithSeparator("~")
                    tasks.append(key)
                    
                    // Link type need to have more than one component
                    if taskNodeType == .Link && nameComponents.count > 1 {
                        
                        // Add transition info
                        fetchedTransitionInfo[key] = value
                    }
                })
                
                // Create node
                switch taskNodeType {
                case .Checklist:
                    node = ChecklistNode(text: finalText, options: tasks)
                    checklistTargetNumberOfTicks = nameInfo.targetNumberOfChoices
                case .Classification:
                    // Add indices
                    var options: [String] = []
                    let count = tasks.count
                    for i in 0..<count {
                        options.append("\(i+1)) \(tasks[i])")
                    }
                    
                    node = ClassificationNode(text: finalText, list: options)
                case .Link, .RadioButtons:
                    node = RadioButtonsNode(text: finalText, options: tasks)
                case .RadioButtonsWithAnswer:
                    let separator = "Answer="
                    var components = finalText.componentsSeparatedByString(separator)
                    
                    // Get answer
                    if components.count > 1 {
                        currentTargetSelectedIndex = Int(components.removeLast())
                    }
                    
                    // Rejoin
                    let text: String = translateText(parseText(components.joinWithSeparator(separator)))
                    
                    // Create RadioButtons
                    node = RadioButtonsNode(text: text, options: tasks)
                default:
                    break
                }
            case .TextField:
                node = TextFieldNode(text: finalText)
            case .TextFieldNumerical:
                node = TextFieldNumericalNode(text: finalText)
            case .TextFieldWithUnit:
                node = TextFieldWithUnitNode(text: finalText, unit: nameInfo.unit ?? "")
            case .TextArea:
                node = TextAreaNode(text: finalText)
            case .TextFieldWithAnswer, .TextAreaWithAnswer:
                let separator = "Answer="
                var components = finalText.componentsSeparatedByString(separator)
                
                // Get answer
                if components.count > 1 {
                    currentTargetTextInput = components.removeLast()
                }
                
                // Rejoin
                let text: String = translateText(parseText(components.joinWithSeparator(separator)))
                
                // Create TextField or TextArea depending on taskNodeType
                node = (taskNodeType == .TextFieldWithAnswer) ? TextFieldNode(text: text) : TextAreaNode(text: text)
            case .TimestampDisplay:
                node = TimestampNode(text: finalText)
            case .Date:
                node = DateNode(text: finalText)
            }
            
            // Get transition info
            currentTransitionInfo = fetchedTransitionInfo
            
            // Get additional transition info if not Decision
            // Decision's transitions were already added in fetchedTransitionInfo
            if type != .Decision {
                let additionalTransitionInfo = transitionInfoFromTransitionIndexers(nodeIndexer[XMLIdentifier.transition].all, andTaskNodeType: taskNodeType)
                for (key, value) in additionalTransitionInfo {
                    currentTransitionInfo[key] = value
                }
            }
        case .EndState:
            node = TextNode(text: "You've now reached the end")
            currentTransitionInfo = [:]
        }
        
        return node
    }
    
    /**
     Gets the transition info from transition indexers. E.g.:
     
     ```
     <transition to="textField~Correct!" name="Yes"></transition>
     <transition to="textField~Incorrect." name="No"></transition>
     ```
     
     - parameters:
       - transitionIndexers: The transition indexers ("transition" XML tags)
       - type: The task node type
     
     - returns: Dictionary of type `[String: String]` which contains task node name and key pairs
    */
    private func transitionInfoFromTransitionIndexers(transitionIndexers: [XMLIndexer], andTaskNodeType type: TaskNodeType) -> [String: String] {
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
    
    // MARK: XML Indexers of task nodes
    
    /**
     Find task-node XML tag with name
     
     - parameter name: value of 'name' in XML tag
     
     - returns: XMLIndexer for the XML tag
    */
    private func taskNodeIndexerWithName(name: String) -> XMLIndexer? {
        return try? processDefinitionIndexer[XMLIdentifier.taskNode].withAttr(XMLIdentifier.name, name)
    }
    
    /**
     Find end-state XML tag with name
     
     - parameter name: value of 'name' in XML tag
     
     - returns: XMLIndexer for the XML tag
    */
    private func endStateIndexerWithName(name: String) -> XMLIndexer? {
        return try? processDefinitionIndexer[XMLIdentifier.endState].withAttr(XMLIdentifier.name, name)
    }
    
    /**
     Find decision XML tag with name
     
     - parameter name: value of 'name' in XML tag
     
     - returns: XMLIndexer for the XML tag
    */
    private func decisionIndexerWithName(name: String) -> XMLIndexer? {
        return try? processDefinitionIndexer[XMLIdentifier.decision].withAttr(XMLIdentifier.name, name)
    }
    
    /**
     Get node indexer and type with name
     
     - parameter name: value of 'name' in XML tag
     
     - returns: An XMLIndexer for the XML tag with the `NodeType`
    */
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
    
    /// XML URL for current language
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
    
    /**
     Translates a text
     
     - parameter text: The text to be translated
     
     - returns: The translated text
    */
    private func translateText(text: String) -> String {
        guard text.characters.count > 0 else {
            return ""
        }
        
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
    
    /**
     Parses a text which contains custom tags
     
     - parameter text: The text to be translated
     
     - returns: The translated text
    */
    private func parseText(text: String) -> String {
        guard text.characters.count > 0 else {
            return ""
        }
        
        return text.stringByReplacingOccurrencesOfString("{br}", withString: "\n", options: .CaseInsensitiveSearch, range: nil)
    }
    
    // MARK: Hints
    
    /// Loads the hints dictionary based on the hints XML for the current language
    private func loadHintsDictionary() {
        hintsDictionary.removeAll()
        for url in hintsXMLURLs {
            // Check if file name is equal to language
            let name = url.URLByDeletingPathExtension?.lastPathComponent ?? "Unknown"
            if currentLanguage == name {
                var hints = [String: String]()
                
                // Fetch hints from XML
                let hintsXML = SWXMLHash.parse(NSData(contentsOfURL: url) ?? NSData())
                let resources = hintsXML[XMLIdentifier.resources]
                
                let stringXMLIndexers = resources[XMLIdentifier.string].all
                for stringXMLIndexer in stringXMLIndexers {
                    if let key = stringXMLIndexer.element?.attributes[XMLIdentifier.name], let value = stringXMLIndexer.element?.text {
                        hints[key] = value
                    }
                }
                
                hintsDictionary = hints
                break
            }
        }
    }
    
    // MARK: End state
    
    /// Checks if current node is an end state node
    public var currentNodeIsEndState: Bool {
        guard let name = taskNodeNames.last else {
            return true
        }
        guard let (_, type) = nodeIndexerAndTypeWithName(name) else {
            return true
        }
        
        return type == .EndState
    }
    
    /// Checks if next node is an end state node
    public var nextNodeIsEndState: Bool {
        guard let name = nextTaskNodeName else {
            return true
        }
        guard let (_, type) = nodeIndexerAndTypeWithName(name) else {
            return true
        }
        
        return type == .EndState
    }
    
    // MARK: Prevent next
    
    /// Checks if node can transition to next node. For example, if checklist node has nothing selected, prevent transition.
    public var shouldPreventTransitionToNextTaskNode: Bool {
        return !(currentNode is ChecklistNode) && currentNodeIsSelectionType && nothingSelected
    }
    
    // MARK: Save state of last node
    
    public func saveStateOfLastNode() {
        let state = UsbongNodeState(transitionName: currentTargetTransitionName, node: currentNode, type: currentTaskNodeType)
        usbongNodeStates.append(state)
    }
}
