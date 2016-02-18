//
//  XMLNameInfo.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/31/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

// MARK: - XMLIdentifier
internal struct XMLIdentifier {
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
internal struct XMLNameInfo {
    static let backgroundImageIdentifier = "bg"
    static let backgroundAudioIdentifier = "bgAudioName"
    static let audioIdentifier = "audioName"
    
    static let supportedImageFormats = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "ico", "cur", "BMPf", "xbm"]
    
    let components: [String]
    let language: String
    let treeRootURL: NSURL
    
    init(name: String, language: String, treeRootURL: NSURL) {
        self.components = name.componentsSeparatedByString("~")
        self.language = language
        self.treeRootURL = treeRootURL
    }
    
    var typeIdentifier: String {
        if components.count > 1 {
            return components.first ?? ""
        } else {
            // Only one component, probably classification
            return "classification"
        }
    }
    
    var type: TaskNodeType? {
        return TaskNodeType(rawValue: typeIdentifier)
    }
    
    var text: String {
        return components.last ?? ""
    }
    
    var imageFileName: String? {
        guard components.count >= 2 else {
            return nil
        }
        return components[1]
    }
    
    var targetNumberOfChoices: Int {
        guard TaskNodeType(rawValue: typeIdentifier) == .Checklist && components.count >= 2 else {
            return 0
        }
        
        return NSString(string: components[1]).integerValue
    }
    
    var imageURL: NSURL? {
        // Make sure imageFileName is nil, else, return nil
        guard let fileName = imageFileName else {
            return nil
        }
        
        let resURL = treeRootURL.URLByAppendingPathComponent("res")
        let imageURLWithoutExtension = resURL.URLByAppendingPathComponent(fileName)
        
        // Check for images with supported image formats
        let fileManager = NSFileManager.defaultManager()
        let supportedImageFormats = XMLNameInfo.supportedImageFormats
        for format in supportedImageFormats {
            let url = imageURLWithoutExtension.URLByAppendingPathExtension(format)
            if let path = url.path {
                if fileManager.fileExistsAtPath(path) {
                    return url
                }
            }
        }
        
        return nil
    }
    var image: UIImage? {
        guard let path = imageURL?.path else {
            return nil
        }
        return UIImage(contentsOfFile: path)
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
        let fullIdentifier = "@" + XMLNameInfo.backgroundImageIdentifier + "="
        return valueOfIdentifer(fullIdentifier) ?? "bg"
    }
    var backgroundImageURL: NSURL? {
        let resURL = treeRootURL.URLByAppendingPathComponent("res")
        
        // Check for images with supported image formats
        let fileManager = NSFileManager.defaultManager()
        guard let contents = try? fileManager.contentsOfDirectoryAtURL(resURL,
            includingPropertiesForKeys: nil, options: .SkipsSubdirectoryDescendants) else {
                return nil
        }
        for content in contents {
            guard let fileName = content.URLByDeletingPathExtension?.lastPathComponent else {
                continue
            }
            
            if fileName.compare(backgroundImageFileName, options: .CaseInsensitiveSearch,
                range: nil, locale: nil) == .OrderedSame {
                    return content
            }
        }
        
        return nil
    }
    
    // MARK: Background audio
    var backgroundAudioFileName: String? {
        let fullIdentifier = "@" + XMLNameInfo.backgroundAudioIdentifier + "="
        return valueOfIdentifer(fullIdentifier)
    }
    var backgroundAudioURL: NSURL? {
        let audioURL = treeRootURL.URLByAppendingPathComponent("audio")
        let targetFileName = backgroundAudioFileName ?? ""
        
        // Finds files in audio/ with file name same to backgroundAudioFileName
        if let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(audioURL,
            includingPropertiesForKeys: nil, options: .SkipsSubdirectoryDescendants) {
                for content in contents {
                    if let fileName = content.URLByDeletingPathExtension?.lastPathComponent {
                        if fileName.compare(targetFileName, options: .CaseInsensitiveSearch,
                            range: nil, locale: nil) == .OrderedSame {
                                return content
                        }
                    }
                }
        }
        
        return nil
    }
    
    // MARK: Audio
    var audioFileName: String? {
        let fullIdentifier = "@" + XMLNameInfo.audioIdentifier + "="
        return valueOfIdentifer(fullIdentifier)
    }
    var audioURL: NSURL? {
        let audioURL = treeRootURL.URLByAppendingPathComponent("audio")
        let audioLanguageURL = audioURL.URLByAppendingPathComponent(language)
        let targetFileName = audioFileName ?? ""
        
        // Find files in audio/{language} with file name same to audioFileName
        if let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(audioLanguageURL,
            includingPropertiesForKeys: nil, options: .SkipsSubdirectoryDescendants) {
                for content in contents {
                    if let fileName = content.URLByDeletingPathExtension?.lastPathComponent {
                        if fileName.compare(targetFileName, options: .CaseInsensitiveSearch,
                            range: nil, locale: nil) == .OrderedSame {
                                return content
                        }
                    }
                }
        }
        
        return nil
    }
    
    // MARK: TextField
    
    var unit: String? {
        guard components.count >= 2 else {
            return nil
        }
        return components[1]
    }
}

internal enum TaskNodeType: String {
    case TextDisplay = "textDisplay"
    case ImageDisplay = "imageDisplay"
    case TextImageDisplay = "textImageDisplay"
    case ImageTextDisplay = "imageTextDisplay"
    case Link = "link"
    case RadioButtons = "radioButtons"
    case Checklist = "checkList"
    case Classification = "classification"
    case TextField = "textField"
    case TextFieldNumerical = "textFieldNumerical"
    case TextFieldWithUnit = "textFieldWithUnit"
}
