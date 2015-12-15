//
//  UsbongTree.swift
//  UsbongKit
//
//  Created by Joe Amanse on 18/11/2015.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation
import SWXMLHash

private struct UsbongXMLIdentifier {
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

private struct UsbongXMLName {
    static let backgroundImageIdentifier = "bg"
    static let backgroundAudioIdentifier = "bgAudioName"
    static let audioIdentifier = "audioName"
    
    let supportedImageFormats = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "ico", "cur", "BMPf", "xbm"]
    
    let components: [String]
    let language: String
    
    init(name: String, language: String = "English") {
        self.components = name.componentsSeparatedByString("~")
        self.language = language
    }
    
    var type: String {
        return components.first ?? ""
    }
    
    var text: String {
        // Parse new line strings and convert it to actual new lines
        return components.last ?? ""
    }
    
    var imageFileName: String? {
        guard components.count >= 2 else {
            return nil
        }
        return components[1]
    }
    var targetNumberOfChoices: Int {
        guard TaskNodeType(rawValue: type) == .CheckList && components.count >= 2 else {
            return 0
        }
        
        return NSString(string: components[1]).integerValue
    }
    
    func imagePathUsingTreeURL(url: NSURL) -> String? {
        // Make sure imageFileName is nil, else, return nil
        guard imageFileName != nil else {
            return nil
        }
        
        let resURL = url.URLByAppendingPathComponent("res")
        let imageURLWithoutExtension = resURL.URLByAppendingPathComponent(imageFileName!)
        
        // Check for images with supported image formats
        let fileManager = NSFileManager.defaultManager()
        for format in supportedImageFormats {
            if let imagePath = imageURLWithoutExtension.URLByAppendingPathExtension(format).path {
                if fileManager.fileExistsAtPath(imagePath) {
                    return imagePath
                }
            }
        }
        
        return nil
    }
    
    // MARK: Fetch value of identifier
    func valueOfIdentifer(identifier: String) -> String? {
        for component in components {
            if component.hasPrefix(identifier) {
                let endIndex = component.startIndex.advancedBy(identifier.characters.count)
                return component.substringFromIndex(endIndex)
            }
        }
        return nil
    }
    
    // MARK: Background image
    var backgroundImageFileName: String {
        let fullIdentifier = "@" + UsbongXMLName.backgroundImageIdentifier + "="
        return valueOfIdentifer(fullIdentifier) ?? "bg"
    }
    func backgroundImagePathUsingXMLURL(url: NSURL) -> String? {
        let resURL = url.URLByAppendingPathComponent("res")
        let imageURLWithoutExtension = resURL.URLByAppendingPathComponent(backgroundImageFileName)
        
        // Check for images with supported image formats
        
        let fileManager = NSFileManager.defaultManager()
        for format in supportedImageFormats {
            if let imagePath = imageURLWithoutExtension.URLByAppendingPathExtension(format).path {
                if fileManager.fileExistsAtPath(imagePath) {
                    return imagePath
                }
            }
        }
        
        return nil
    }
    
    // MARK: Background audio
    var backgroundAudioFileName: String? {
        let fullIdentifier = "@" + UsbongXMLName.backgroundAudioIdentifier + "="
        return valueOfIdentifer(fullIdentifier)
    }
    func backgroundAudioPathUsingXMLURL(url: NSURL) -> String? {
        let audioURL = url.URLByAppendingPathComponent("audio")
        let targetFileName = backgroundAudioFileName ?? ""
        
        // Finds files in audio/ with file name same to backgroundAudioFileName
        if let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(audioURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants) {
            for content in contents {
                if let fileName = content.URLByDeletingPathExtension?.lastPathComponent {
                    if fileName.compare(targetFileName, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) == .OrderedSame {
                        return content.path
                    }
                }
            }
        }
        return nil
    }
    
    // MARK: Audio
    var audioFileName: String? {
        let fullIdentifier = "@" + UsbongXMLName.audioIdentifier + "="
        return valueOfIdentifer(fullIdentifier)
    }
    func audioPathUsingXMLURL(url: NSURL) -> String? {
        let audioURL = url.URLByAppendingPathComponent("audio")
        let audioLanguageURL = audioURL.URLByAppendingPathComponent(language)
        let targetFileName = audioFileName ?? ""
        
        // Find files in audio/{language} with file name same to audioFileName
        if let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(audioLanguageURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants) {
            for content in contents {
                if let fileName = content.URLByDeletingPathExtension?.lastPathComponent {
                    if fileName.compare(targetFileName, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) == .OrderedSame {
                        return content.path
                    }
                }
            }
        }
        
        return nil
    }
}

private enum TaskNodeType: String {
    case TextDisplay = "textDisplay"
    case ImageDisplay = "imageDisplay"
    case TextImageDisplay = "textImageDisplay"
    case ImageTextDisplay = "imageTextDisplay"
    case Link = "link"
    case RadioButtons = "radioButtons"
    case CheckList = "checkList"
}

private func languageCodeOfLanguage(language: String) -> String {
    switch language {
    case "English":
        return "en-EN"
    case "Czech":
        return "cs-CZ"
    case "Danish":
        return "da-DK"
    case "German":
        return "de-DE"
    case "Greek":
        return "el-GR"
    case "Spanish", "Bisaya", "Ilonggo", "Tagalog", "Filipino":
        return "es-ES"
    case "Finnish":
        return "fi-FI"
    case "French":
        return "fr-FR"
    case "Hindi":
        return "hi-IN"
    case "Hungarian":
        return "hu-HU"
    case "Indonesian":
        return "id-ID"
    case "Italian":
        return "it-IT"
    case "Japanese":
        return "ja-JP"
    case "Korean":
        return "ko-KR"
    case "Dutch":
        return "nl-BE"
    case "Norwegian":
        return "nb-NO"
    case "Polish":
        return "pl-PL"
    case "Portuguese":
        return "pt-PT"
    case "Romanian":
        return "ro-RO"
    case "Russian":
        return "ru-RU"
    case "Slovak":
        return "sk-SK"
    case "Swedish":
        return "sv-SE"
    case "Thai":
        return "th-TH"
    case "Turkish":
        return "tr-TR"
    case "Chinese":
        return "zh-CN"
    default:
        return "en-EN"
    }
}

public class UsbongTree {
    public let treeRootURL: NSURL
    public let xmlURL: NSURL
    
    public var taskNodeNames: [String] = []
    
    public private(set) var title: String = "Title"
    public private(set) var baseLanguage: String = "English"
    public var currentLanguage: String = "English" {
        didSet {
            reloadCurrentTaskNode()
            reloadHintsDictionary()
        }
    }
    public var currentLanguageCode: String {
        return languageCodeOfLanguage(currentLanguage)
    }
    
    private let wholeXML: XMLIndexer
    private let processDefinition: XMLIndexer
    
    public private(set) var currentTaskNode: TaskNode?
    private var currentTaskNodeType: TaskNodeType = .TextDisplay
    
    public var currentTargetTransitionName: String {
        get {
            // If current task node type is radio buttons, ignore selected module (transition to any)
            if let taskNode = currentTaskNode where currentTaskNodeType != .RadioButtons {
                switch taskNode {
                case let linkTaskNode as LinkTaskNode:
                    if let linkModule = linkTaskNode.currentSelectedModule {
                        return linkModule.taskIdentifier
                    }
                case let checkListTaskNode as CheckListTaskNode:
                    if checkListTaskNode.reachedTarget {
                        return "Yes"
                    } else {
                        return "No"
                    }
                default:
                    break
                }
            }
            return "Any"
        }
    }
    public var transitionInfo: [String: String] = [String: String]()
    
    private let languageXMLURLs: [NSURL]
    public let availableLanguages: [String]
    
    private let hintsXMLURLs: [NSURL]
    public private(set) var hintsDictionary: [String: String] = [String: String]()
    
    public init(treeRootURL: NSURL) {
        self.treeRootURL = treeRootURL
        
        // Fetch main xml
        let fileName = treeRootURL.URLByDeletingPathExtension?.lastPathComponent ?? ""
        xmlURL = treeRootURL.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("xml")
        
        wholeXML = SWXMLHash.parse(NSData(contentsOfURL: xmlURL) ?? NSData())
        processDefinition = wholeXML[UsbongXMLIdentifier.processDefinition]
        
        // Fetch language XMLs urls
        // Get trans directory
        let transURL = treeRootURL.URLByAppendingPathComponent("trans")
        // Fetch contents of trans directory
        languageXMLURLs = (try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(transURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants)) ?? []
        
        // Get available languages
        var languages: [String] = []
        for url in languageXMLURLs {
            // Get file name only
            let name = url.URLByDeletingPathExtension?.lastPathComponent ?? "Unknown"
            languages.append(name)
        }
        
        // Add base language
        if !languages.contains(baseLanguage) {
            languages.append(baseLanguage)
            languages.sortInPlace()
        }
        availableLanguages = languages
        
        // Get hints directory
        let hintsURL = treeRootURL.URLByAppendingPathComponent("hints")
        
        // Fetch contents of hints directory
        hintsXMLURLs = (try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(hintsURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants)) ?? []
        reloadHintsDictionary()
        
        // Get language
        baseLanguage = processDefinition.element?.attributes[UsbongXMLIdentifier.lang] ?? baseLanguage
        currentLanguage = baseLanguage
        
        // Set title to file name if file name is not blank or contains spaces only
        title = fileName.stringByReplacingOccurrencesOfString(" ", withString: "").characters.count == 0 ? title : fileName
        
        
        // Fetch starting task node
        if let element = processDefinition[UsbongXMLIdentifier.startState][UsbongXMLIdentifier.transition].element {
            if let startName = element.attributes[UsbongXMLIdentifier.to] {
                // Add to task node names history
                taskNodeNames.append(startName)
            }
        }
        if let name = taskNodeNames.first {
            currentTaskNode = taskNodeWithName(name)
        }
    }
    
    public func taskNodeWithName(name: String) -> TaskNode? {
        // task-node
        var taskNode: TaskNode? = nil
        // Find task-node element with attribute name value
        if let taskNodeXMLIndexer = taskNodeXMLIndexerWithName(name) {
            let nameComponents = UsbongXMLName(name: name, language: currentLanguage)
            if let taskNodeType = TaskNodeType(rawValue: nameComponents.type) {
                // Translate text if current language is not base language
                let translatedText = currentLanguage != baseLanguage ? translateText(nameComponents.text) : nameComponents.text
                
                // Parse text
                let finalText = parseText(translatedText)
                
                // Temporary transition info to be used by link and decision task nodes
                var fetchedTransitionInfo: [String: String] = [:]
                
                currentTaskNodeType = taskNodeType
                switch taskNodeType {
                case .TextDisplay:
                    taskNode =  TextDisplayTaskNode(text: finalText)
                case .ImageDisplay:
                    taskNode =  ImageDisplayTaskNode(imageFilePath: nameComponents.imagePathUsingTreeURL(treeRootURL) ?? "")
                case .TextImageDisplay:
                    taskNode = TextImageDisplayTaskNode(text: finalText, imageFilePath: nameComponents.imagePathUsingTreeURL(treeRootURL) ?? "")
                case .ImageTextDisplay:
                    taskNode = ImageTextDisplayTaskNode(imageFilePath: nameComponents.imagePathUsingTreeURL(treeRootURL) ?? "", text: finalText)
                case .Link, .RadioButtons, .CheckList:
                    var tasks: [LinkTaskNodeTask] = []
                    // Fetch tasks (and transition info from task elements if link)
                    let taskXMLIndexers = taskNodeXMLIndexer[UsbongXMLIdentifier.task].all
                    for taskXMLIndexer in taskXMLIndexers {
                        if let name = taskXMLIndexer.element?.attributes[UsbongXMLIdentifier.name] {
                            var nameComponents = name.componentsSeparatedByString("~")
                            
                            // Link type need to have more than one component
                            let minimumCount = taskNodeType == .Link ? 1 : 0
                            if nameComponents.count > minimumCount {
                                let key = nameComponents.removeLast()
                                
                                // TODO: Translate here
                                let translatedKey = key
                                tasks.append(LinkTaskNodeTask(identifier: key, value: translatedKey))
                                
                                // Add transition info only if link type
                                if taskNodeType == .Link {
                                    let value = nameComponents.joinWithSeparator("~")
                                    fetchedTransitionInfo[key] = value
                                }
                            }
                        }
                    }
                    
                    if taskNodeType == .CheckList {
                        // Create check list task node
                        taskNode = CheckListTaskNode(text: finalText, tasks: tasks, targetNumberOfChoices: nameComponents.targetNumberOfChoices)
                    } else {
                        // Create link task node
                        taskNode = LinkTaskNode(text: finalText, tasks: tasks)
                    }
                }
                
                // Fetch transition info from transition elements
                let transitionElements = taskNodeXMLIndexer[UsbongXMLIdentifier.transition].all
                for transitionElement in transitionElements {
                    if let attributes = transitionElement.element?.attributes {
                        // Get values of attributes name and to, add to taskNode object
                        let name = attributes[UsbongXMLIdentifier.name] ?? "Any" // Default is Any if no name found
                        
                        var to = attributes[UsbongXMLIdentifier.to] ?? ""
                        
                        // Remove identifier for link transition
                        if taskNodeType == .Link {
                            var components = to.componentsSeparatedByString("~")
                            components.removeLast()
                            to = components.joinWithSeparator("~")
                        }
                        
                        // Save transition info
                        fetchedTransitionInfo[name] = to
                    }
                }
                transitionInfo = fetchedTransitionInfo
                
                // Background Path
                taskNode?.backgroundImageFilePath = nameComponents.backgroundImagePathUsingXMLURL(treeRootURL)
                
                // Audio Paths
                taskNode?.backgroundAudioFilePath = nameComponents.backgroundAudioPathUsingXMLURL(treeRootURL)
                taskNode?.audioFilePath = nameComponents.audioPathUsingXMLURL(treeRootURL)
            }
            
        } else if (try? processDefinition[UsbongXMLIdentifier.endState].withAttr(UsbongXMLIdentifier.name, name)) != nil {
            // Find end-state node if task-node not found
            taskNode =  EndStateTaskNode(text: "You've now reached the end")
        } else if let decisionXMLIndexer = try? processDefinition[UsbongXMLIdentifier.decision].withAttr(UsbongXMLIdentifier.name, name) {
            // Decision Node
            let nameComponents = UsbongXMLName(name: name, language: currentLanguage)
            
            // Translate text if current language is not base language
            let translatedText = currentLanguage != baseLanguage ? translateText(nameComponents.text) : nameComponents.text
            
            // Parse text
            let finalText = parseText(translatedText)
            
            // Temporary transition info to be used by link and decision task nodes
            var fetchedTransitionInfo: [String: String] = [:]
            var tasks: [LinkTaskNodeTask] = []
            
            // Fetch transition info from transition elements
            let transitionElements = decisionXMLIndexer[UsbongXMLIdentifier.transition].all
            for transitionElement in transitionElements {
                if let attributes = transitionElement.element?.attributes {
                    // Get values of attributes name and to, add to taskNode object
                    let key = attributes[UsbongXMLIdentifier.name] ?? "Any" // Default is Any if no name found
                    
                    // TODO: Translate here
                    let translatedKey = key
                    
                    tasks.append(LinkTaskNodeTask(identifier: key, value: translatedKey))
                    
                    // Save transition info
                    fetchedTransitionInfo[key] = attributes[UsbongXMLIdentifier.to] ?? ""
                }
            }
            transitionInfo = fetchedTransitionInfo
            
            taskNode = LinkTaskNode(text: finalText, tasks: tasks)
            
            // Background Path
            taskNode?.backgroundImageFilePath = nameComponents.backgroundImagePathUsingXMLURL(treeRootURL)
            
            // Audio Paths
            taskNode?.backgroundAudioFilePath = nameComponents.backgroundAudioPathUsingXMLURL(treeRootURL)
            taskNode?.audioFilePath = nameComponents.audioPathUsingXMLURL(treeRootURL)
        }
        
        return taskNode
    }
    
    private func parseText(text: String) -> String {
        var currentText = text
        
        // Replace markups
        currentText = currentText.stringByReplacingOccurrencesOfString("{br}", withString: "\n")
        
        return currentText
    }
    
    // MARK: Convenience
    private func taskNodeXMLIndexerWithName(name: String) -> XMLIndexer? {
        return try? processDefinition[UsbongXMLIdentifier.taskNode].withAttr(UsbongXMLIdentifier.name, name)
    }
    private func endStateXMLIndexerWithName(name: String) -> XMLIndexer? {
        return try? processDefinition[UsbongXMLIdentifier.endState].withAttr(UsbongXMLIdentifier.name, name)
    }
    private func decisionXMLIndexerWithName(name: String) -> XMLIndexer? {
        return try? processDefinition[UsbongXMLIdentifier.decision].withAttr(UsbongXMLIdentifier.name, name)
    }
    
    private var nextTaskNodeName: String? {
        return transitionInfo[currentTargetTransitionName]
    }
    
    public func reloadCurrentTaskNode() {
        if let currentTaskNodeName = taskNodeNames.last {
            currentTaskNode = taskNodeWithName(currentTaskNodeName)
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
            let resources = languageXML[UsbongXMLIdentifier.resources]
            
            if let stringElement = try? resources[UsbongXMLIdentifier.string].withAttr(UsbongXMLIdentifier.name, text) {
                translatedText = stringElement.element?.text ?? text
            }
        }
        
        return translatedText
    }
    
    // MARK: Hints
    public func reloadHintsDictionary() {
        hintsDictionary.removeAll()
        for url in hintsXMLURLs {
            // Check if file name is equal to language
            let name = url.URLByDeletingPathExtension?.lastPathComponent ?? "Unknown"
            if currentLanguage == name {
                var hints = [String: String]()
                
                // Fetch hints from XML
                let hintsXML = SWXMLHash.parse(NSData(contentsOfURL: url) ?? NSData())
                let resources = hintsXML[UsbongXMLIdentifier.resources]
                
                let stringXMLIndexers = resources[UsbongXMLIdentifier.string].all
                for stringXMLIndexer in stringXMLIndexers {
                    if let key = stringXMLIndexer.element?.attributes[UsbongXMLIdentifier.name], let value = stringXMLIndexer.element?.text {
                        hints[key] = value
                    }
                }
                
                hintsDictionary = hints
                break
            }
        }
    }
    
    // MARK: Transitions
    public func transitionToNextTaskNode() -> Bool {
        // Get next task node name
        if let name = nextTaskNodeName {
            print(name)
            if let taskNode = taskNodeWithName(name) {
                currentTaskNode = taskNode
                taskNodeNames.append(name)
                return true
            }
        }
        return false
    }
    
    public func transitionToPreviousTaskNode() -> Bool {
        // Remove current task node name
        if taskNodeNames.count > 1 {
            taskNodeNames.removeLast()
            
            if let currentTaskNodeName = taskNodeNames.last {
                currentTaskNode = taskNodeWithName(currentTaskNodeName)
                return true
            }
        }
        return false
    }
    
    // MARK: Availability check
    public var nextTaskNodeIsAvailable: Bool {
        if let name = nextTaskNodeName {
            return (taskNodeXMLIndexerWithName(name) != nil || decisionXMLIndexerWithName(name) != nil || endStateXMLIndexerWithName(name) != nil)
        }
        return false
    }
    public var previousTaskNodeIsAvailable: Bool {
        return taskNodeNames.count > 1
    }
    
    public var noSelection: Bool {
        if let linkTaskNode = currentTaskNode as? LinkTaskNode {
            if linkTaskNode.currentSelectedIndex < 0 {
                return true
            }
            return false
        }
        return false
    }
}
