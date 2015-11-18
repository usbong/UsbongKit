//
//  UsbongTaskNodeGeneratorXML.swift
//  usbong
//
//  Created by Chris Amanse on 01/10/2015.
//  Copyright 2015 Usbong Social Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import SWXMLHash

//private struct UsbongXMLIdentifier {
//    static let processDefinition = "process-definition"
//    static let startState = "start-state"
//    static let endState = "end-state"
//    static let taskNode = "task-node"
//    static let transition = "transition"
//    static let to = "to"
//    static let name = "name"
//    
//    static let resources = "resources"
//    static let string = "string"
//}
//
//private struct UsbongXMLName {
//    static let backgroundImageIdentifier = "bg"
//    static let backgroundAudioIdentifier = "bgAudioName"
//    static let audioIdentifier = "audioName"
//    
//    
//    let supportedImageFormats = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "ico", "cur", "BMPf", "xbm"]
//    
//    let components: [String]
//    let language: String
//    
//    init(name: String, language: String = "English") {
//        self.components = name.componentsSeparatedByString("~")
//        self.language = language
//    }
//    
//    var type: String {
//        return components.first ?? ""
//    }
//    
//    var text: String {
//        // Parse new line strings and convert it to actual new lines
//        return components.last ?? ""
//    }
//    
//    var imageFileName: String? {
//        guard components.count >= 2 else {
//            return nil
//        }
//        return components[1]
//    }
//    
//    func imagePathUsingTreeURL(url: NSURL) -> String? {
//        // Make sure imageFileName is nil, else, return nil
//        guard imageFileName != nil else {
//            return nil
//        }
//        
//        let resURL = url.URLByAppendingPathComponent("res")
//        let imageURLWithoutExtension = resURL.URLByAppendingPathComponent(imageFileName!)
//        
//        // Check for images with supported image formats
//        let fileManager = NSFileManager.defaultManager()
//        for format in supportedImageFormats {
//            if let imagePath = imageURLWithoutExtension.URLByAppendingPathExtension(format).path {
//                if fileManager.fileExistsAtPath(imagePath) {
//                    return imagePath
//                }
//            }
//        }
//        
//        return nil
//    }
//    
//    // MARK: Fetch value of identifier
//    func valueOfIdentifer(identifier: String) -> String? {
//        for component in components {
//            if component.hasPrefix(identifier) {
//                let endIndex = component.startIndex.advancedBy(identifier.characters.count)
//                return component.substringFromIndex(endIndex)
//            }
//        }
//        return nil
//    }
//    
//    // MARK: Background image
//    
//    var backgroundImageFileName: String {
//        let fullIdentifier = "@" + UsbongXMLName.backgroundImageIdentifier + "="
//        return valueOfIdentifer(fullIdentifier) ?? "bg"
//    }
//    func backgroundImagePathUsingXMLURL(url: NSURL) -> String? {
//        let resURL = url.URLByAppendingPathComponent("res")
//        let imageURLWithoutExtension = resURL.URLByAppendingPathComponent(backgroundImageFileName)
//        
//        // Check for images with supported image formats
//        
//        let fileManager = NSFileManager.defaultManager()
//        for format in supportedImageFormats {
//            if let imagePath = imageURLWithoutExtension.URLByAppendingPathExtension(format).path {
//                if fileManager.fileExistsAtPath(imagePath) {
//                    return imagePath
//                }
//            }
//        }
//        
//        return nil
//    }
//    
//    // MARK: Background audio
//    var backgroundAudioFileName: String? {
//        let fullIdentifier = "@" + UsbongXMLName.backgroundAudioIdentifier + "="
//        return valueOfIdentifer(fullIdentifier)
//    }
//    func backgroundAudioPathUsingXMLURL(url: NSURL) -> String? {
//        let audioURL = url.URLByAppendingPathComponent("audio")
//        let targetFileName = backgroundAudioFileName ?? ""
//        
//        // Finds files in audio/ with file name same to backgroundAudioFileName
//        if let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(audioURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants) {
//            for content in contents {
//                if let fileName = content.URLByDeletingPathExtension?.lastPathComponent {
//                    if fileName.compare(targetFileName, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) == .OrderedSame {
//                        return content.path
//                    }
//                }
//            }
//        }
//        return nil
//    }
//    
//    // MARK: Audio
//    var audioFileName: String? {
//        let fullIdentifier = "@" + UsbongXMLName.audioIdentifier + "="
//        return valueOfIdentifer(fullIdentifier)
//    }
//    func audioPathUsingXMLURL(url: NSURL) -> String? {
//        let audioURL = url.URLByAppendingPathComponent("audio")
//        let audioLanguageURL = audioURL.URLByAppendingPathComponent(language)
//        let targetFileName = audioFileName ?? ""
//        
//        // Find files in audio/{language} with file name same to audioFileName
//        if let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(audioLanguageURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants) {
//            for content in contents {
//                if let fileName = content.URLByDeletingPathExtension?.lastPathComponent {
//                    if fileName.compare(targetFileName, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) == .OrderedSame {
//                        return content.path
//                    }
//                }
//            }
//        }
//        
//        return nil
//    }
//}
//
//public class UsbongTaskNodeGeneratorXML: UsbongTaskNodeGenerator {
//    // MARK: - Properties
//    public let treeRootURL: NSURL
//    public let xmlURL: NSURL
//    
//    public var xml: XMLIndexer
//    public var processDefinition: XMLIndexer
//    
//    public var currentTransitionInfo: [String: String] = [String: String]()
//    public var currentTargetTransitionName: String = "Any"
//    
//    public var baseLanguage: String = "English"
//    
//    public var taskNodeNames: [String] = []
//    public var title: String = "Unnamed"
//    public private(set) var hintsDictionary: [String: String] = [String: String]()
//    
//    // MARK: Initializers
//    public init(treeRootURL: NSURL) {
//        self.treeRootURL = treeRootURL
//        
//        let fileName = treeRootURL.lastPathComponent?.componentsSeparatedByString(".").first ?? ""
//        xmlURL = treeRootURL.URLByAppendingPathComponent("\(fileName).xml")
//        xml = SWXMLHash.parse(NSData(contentsOfURL: xmlURL) ?? NSData())
//        processDefinition = xml[UsbongXMLIdentifier.processDefinition]
//        
//        // Get language
//        baseLanguage = processDefinition.element?.attributes["lang"] ?? baseLanguage
//        
//        // Fetch hints dictionary for current language
//        fetchHintsDictionary()
//        
//        // Set to "Unnamed" if fileName is blank or contains spaces only
//        title = fileName.stringByReplacingOccurrencesOfString(" ", withString: "").characters.count == 0 ? "Unnamed" : fileName
//        
//        // Load starting task node
//        loadStartingTaskNode()
//    }
//    
//    // MARK: - Fetching from XML
//    
//    private func loadStartingTaskNode() {
//        if let startName = fetchStartingTaskNodeName() {
//            taskNodeNames.append(startName)
//            fetchTransitionInfoFromTaskNodeName(startName)
//        }
//    }
//    private func fetchStartingTaskNodeName() -> String? {
//        if let element = processDefinition[UsbongXMLIdentifier.startState][UsbongXMLIdentifier.transition].element {
//            return element.attributes[UsbongXMLIdentifier.to]
//        }
//        return nil
//    }
//    
//    public func fetchTaskNodeWithName(name: String) -> TaskNode? {
//        // task-node
//        var taskNode: TaskNode?
//        // Find task-node element with attribute name value
//        if (try? processDefinition[UsbongXMLIdentifier.taskNode].withAttr(UsbongXMLIdentifier.name, name)) != nil {
//            let nameComponents = UsbongXMLName(name: name, language: currentLanguage)
//            let type = nameComponents.type
//            
//            // Translate text if current language is not base language
//            let translatedText = currentLanguage != baseLanguage ? translateText(nameComponents.text) : nameComponents.text
//            
//            // Parse text
//            let finalText = parseText(translatedText)
//            
//            switch type {
//            case TextDisplayTaskNode.type:
//                taskNode =  TextDisplayTaskNode(text: finalText)
//            case ImageDisplayTaskNode.type:
//                taskNode =  ImageDisplayTaskNode(imageFilePath: nameComponents.imagePathUsingTreeURL(treeRootURL) ?? "")
//            case TextImageDisplayTaskNode.type:
//                taskNode = TextImageDisplayTaskNode(text: finalText, imageFilePath: nameComponents.imagePathUsingTreeURL(treeRootURL) ?? "")
//            case ImageTextDisplayTaskNode.type:
//                taskNode = ImageTextDisplayTaskNode(imageFilePath: nameComponents.imagePathUsingTreeURL(treeRootURL) ?? "", text: finalText)
//            case LinkTaskNode.type:
//                taskNode = LinkTaskNode(text: finalText, tasks: [String]())
//            default:
//                taskNode = nil
//            }
//            
//            // Background Path
//            taskNode?.backgroundImageFilePath = nameComponents.backgroundImagePathUsingXMLURL(treeRootURL)
//            
//            // Audio Paths
//            taskNode?.backgroundAudioFilePath = nameComponents.backgroundAudioPathUsingXMLURL(treeRootURL)
//            taskNode?.audioFilePath = nameComponents.audioPathUsingXMLURL(treeRootURL)
//        } else if (try? processDefinition[UsbongXMLIdentifier.endState].withAttr(UsbongXMLIdentifier.name, name)) != nil {
//            // Find end-state node if task-node not found
//            taskNode =  EndStateTaskNode(text: "You've now reached the end")
//        }
//        
//        return taskNode
//    }
//    
//    public func fetchTransitionInfoFromTaskNodeName(name: String) {
//        if let taskNodeElement = try? processDefinition[UsbongXMLIdentifier.taskNode].withAttr(UsbongXMLIdentifier.name, name) {
//            let transitionElements = taskNodeElement[UsbongXMLIdentifier.transition].all
//            for transitionElement in transitionElements {
//                if let attributes = transitionElement.element?.attributes {
//                    // Get values of attributes name and to, add to taskNode object
//                    let name = attributes["name"] ?? "Any" // Default is Any if no name found
//                    
//                    // Save transition info
//                    currentTransitionInfo[name] = attributes[UsbongXMLIdentifier.to] ?? ""
//                }
//            }
//        }
//    }
//    
//    private func fetchLanguageXMLURLs() -> [NSURL]? {
//        // Get trans directory
//        let transURL = treeRootURL.URLByAppendingPathComponent("trans")
//        
//        // Fetch contents of trans directory
//        if let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(transURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants) {
//            return contents
//        }
//        return nil
//    }
//    private func fetchLanguageXMLURLForLanguage(language: String) -> NSURL? {
//        if let urls = fetchLanguageXMLURLs() {
//            for url in urls {
//                // Check if file name is equal to language
//                let name = url.URLByDeletingPathExtension?.lastPathComponent ?? "Unknown"
//                if language == name {
//                    return url
//                }
//            }
//        }
//        
//        return nil
//    }
//    
//    private func fetchLanguages() -> [String] {
//        var languages: [String] = []
//        if let urls = fetchLanguageXMLURLs() {
//            for url in urls {
//                // Get file name only
//                let name = url.URLByDeletingPathExtension?.lastPathComponent ?? "Unknown"
//                languages.append(name)
//            }
//        }
//        return languages
//    }
//    
//    public func fetchHintsXMLURLs() -> [NSURL]? {
//        // Get hints directory
//        let hintsURL = treeRootURL.URLByAppendingPathComponent("hints")
//        
//        // Fetch contents of hints directory
//        if let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(hintsURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants) {
//            return contents
//        }
//        return nil
//    }
//    
//    public func fetchHintsXMLURLForLanguage(language: String) -> NSURL? {
//        if let urls = fetchHintsXMLURLs() {
//            for url in urls {
//                // Check if file name is equal to language
//                let name = url.URLByDeletingPathExtension?.lastPathComponent ?? "Unknown"
//                if language == name {
//                    return url
//                }
//            }
//        }
//        return nil
//    }
//    
//    public func fetchHintsDictionary() {
//        var hints = [String: String]()
//        
//        // Fetch hints from XML
//        if let hintsXMLURL = fetchHintsXMLURLForLanguage(currentLanguage) {
//            let hintsXML = SWXMLHash.parse(NSData(contentsOfURL: hintsXMLURL) ?? NSData())
//            let resources = hintsXML[UsbongXMLIdentifier.resources]
//            
//            let stringXMLIndexers = resources[UsbongXMLIdentifier.string].all
//            for stringXMLIndexer in stringXMLIndexers {
//                if let key = stringXMLIndexer.element?.attributes[UsbongXMLIdentifier.name], let value = stringXMLIndexer.element?.text {
//                    hints[key] = value
//                }
//            }
//        }
//        
//        hintsDictionary = hints
//    }
//    
//    public var nextTaskNodeName: String? {
//        return currentTransitionInfo[currentTargetTransitionName]
//    }
//    private func nextTaskNodeWithTransitionName(transitionName: String) -> TaskNode? {
//        if let taskNodeName = currentTransitionInfo[transitionName] {
//            return fetchTaskNodeWithName(taskNodeName)
//        }
//        return nil
//    }
//    
//    // MARK: - Translation and parsing
//    
//    public func translateText(text: String) -> String {
//        var translatedText = text
//        
//        // Fetch translation from XML
//        if let languageXMLURL = fetchLanguageXMLURLForLanguage(currentLanguage) {
//            let languageXML = SWXMLHash.parse(NSData(contentsOfURL: languageXMLURL) ?? NSData())
//            let resources = languageXML[UsbongXMLIdentifier.resources]
//            
//            if let stringElement = try? resources[UsbongXMLIdentifier.string].withAttr(UsbongXMLIdentifier.name, text) {
//                translatedText = stringElement.element?.text ?? text
//            }
//        }
//        
//        return translatedText
//    }
//    
//    public func parseText(text: String) -> String {
//        var parsedText = text
//        
//        // Parse new line strings
//        parsedText = parsedText.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
//        
//        return parsedText
//    }
//    
//    // MARK: - UsbongTaskNodeGenerator
//    
//    public var currentLanguage: String = "English" {
//        didSet {
//            fetchHintsDictionary()
//        }
//    }
//    public var currentLanguageCode: String {
//        switch currentLanguage {
//        case "English":
//            return "en-EN"
//        case "Czech":
//            return "cs-CZ"
//        case "Danish":
//            return "da-DK"
//        case "German":
//            return "de-DE"
//        case "Greek":
//            return "el-GR"
//        case "Spanish", "Bisaya", "Ilonggo", "Tagalog":
//            return "es-ES"
//        case "Finnish":
//            return "fi-FI"
//        case "French":
//            return "fr-FR"
//        case "Hindi":
//            return "hi-IN"
//        case "Hungarian":
//            return "hu-HU"
//        case "Indonesian":
//            return "id-ID"
//        case "Italian":
//            return "it-IT"
//        case "Japanese":
//            return "ja-JP"
//        case "Korean":
//            return "ko-KR"
//        case "Dutch":
//            return "nl-BE"
//        case "Norwegian":
//            return "nb-NO"
//        case "Polish":
//            return "pl-PL"
//        case "Portuguese":
//            return "pt-PT"
//        case "Romanian":
//            return "ro-RO"
//        case "Russian":
//            return "ru-RU"
//        case "Slovak":
//            return "sk-SK"
//        case "Swedish":
//            return "sv-SE"
//        case "Thai":
//            return "th-TH"
//        case "Turkish":
//            return "tr-TR"
//        case "Chinese":
//            return "zh-CN"
//        default:
//            return "en-EN"
//        }
//    }
//    public var availableLanguages: [String] {
//        var languages = fetchLanguages()
//        // Add base language
//        if !languages.contains(baseLanguage) {
//            languages.append(baseLanguage)
//            languages.sortInPlace()
//        }
//        return languages
//    }
//    
//    public var taskNodesCount: Int {
//        return taskNodeNames.count
//    }
//    public var previousTaskNode: TaskNode? {
//        guard taskNodeNames.count > 1 else {
//            return nil
//        }
//        return fetchTaskNodeWithName(taskNodeNames[taskNodeNames.count - 2])
//    }
//    public var currentTaskNode: TaskNode? {
//        if let name = taskNodeNames.last {
//            return fetchTaskNodeWithName(name)
//        }
//        return nil
//    }
//    public var nextTaskNode: TaskNode? {
//        if let name = nextTaskNodeName {
//            return fetchTaskNodeWithName(name)
//        }
//        return nil
//    }
//    
//    public func transitionToNextTaskNode() -> Bool {
//        if let taskNodeName = self.nextTaskNodeName {
//            taskNodeNames.append(taskNodeName)
//            
//            fetchTransitionInfoFromTaskNodeName(taskNodeNames.last ?? "")
//        }
//        return false
//    }
//    public func transitionToPreviousTaskNode() -> Bool {
//        if taskNodeNames.count > 1 {
//            taskNodeNames.removeLast()
//            
//            fetchTransitionInfoFromTaskNodeName(taskNodeNames.last ?? "")
//        }
//        return false
//    }
//}