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
    
    private func nodeWithName(taskNodeName: String) -> Node {
        return Node(modules: [TextModule(text: "Unknown Node")])
    }
}

// MARK: - XMLIdentifier
private class XMLIdentifier {
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

// MARK: - XMLName
private struct XMLName {
    static let backgroundImageIdentifier = "bg"
    static let backgroundAudioIdentifier = "bgAudioName"
    static let audioIdentifier = "audioName"
    
    static let supportedImageFormats = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "ico", "cur", "BMPf", "xbm"]
    
    let components: [String]
    let language: String
    
    init(name: String, language: String = "English") {
        self.components = name.componentsSeparatedByString("~")
        self.language = language
    }
    
    var type: String {
        if components.count > 1 {
            return components.first ?? ""
        } else {
            // Only one component, probably classification
            return "classification"
        }
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
        guard NodeIdentifier(rawValue: type) == .CheckList && components.count >= 2 else {
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
        let supportedImageFormats = XMLName.supportedImageFormats
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
        let fullIdentifier = "@" + XMLName.backgroundImageIdentifier + "="
        return valueOfIdentifer(fullIdentifier) ?? "bg"
    }
    func backgroundImagePathUsingXMLURL(url: NSURL) -> String? {
        let resURL = url.URLByAppendingPathComponent("res")
        let imageURLWithoutExtension = resURL.URLByAppendingPathComponent(backgroundImageFileName)
        
        // Check for images with supported image formats
        
        let fileManager = NSFileManager.defaultManager()
        let supportedImageFormats = XMLName.supportedImageFormats
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
        let fullIdentifier = "@" + XMLName.backgroundAudioIdentifier + "="
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
        let fullIdentifier = "@" + XMLName.audioIdentifier + "="
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

private enum NodeIdentifier: String {
    case TextDisplay = "textDisplay"
    case ImageDisplay = "imageDisplay"
    case TextImageDisplay = "textImageDisplay"
    case ImageTextDisplay = "imageTextDisplay"
    case Link = "link"
    case RadioButtons = "radioButtons"
    case CheckList = "checkList"
}
