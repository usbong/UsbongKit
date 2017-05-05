//
//  XMLNameInfo.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/31/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

/// Decomposes a task node name into components
internal struct XMLNameInfo {
    /// Background image identifier
    static let backgroundImageIdentifier = "bg"
    
    /// Background audio identifier
    static let backgroundAudioIdentifier = "bgAudioName"
    
    /// Audio identifier
    static let audioIdentifier = "audioName"
    
    /// Supported image formats
    static let supportedImageFormats = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "ico", "cur", "BMPf", "xbm"]
    
    /// Components of string (separated by "~")
    let components: [String]
    
    /// Target language
    let language: String
    
    
    /// Tree root URL. Used for getting resources.
    let treeRootURL: URL
    
    /// Creates an `XMLNameInfo` from `name`, `language`, and `treeRootURL`
    init(name: String, language: String, treeRootURL: URL) {
        self.components = name.components(separatedBy: "~")
        self.language = language
        self.treeRootURL = treeRootURL
    }
    
    /// The type identifier for the task node. It is usually the first component. For `classification` type task node, there is no type identifier.
    var typeIdentifier: String {
        if components.count > 1 {
            return components.first ?? ""
        } else {
            // Only one component, probably classification
            return "classification"
        }
    }
    
    /// The `TaskNodeType`, which is based on the type identifier
    var type: TaskNodeType? {
        return TaskNodeType(rawValue: typeIdentifier)
    }
    
    /// The text for the task node
    var text: String {
        return components.last ?? ""
    }
    
    /// The image file name
    var imageFileName: String? {
        guard components.count >= 2 else {
            return nil
        }
        return components[1]
    }
    
    /// The target number of choices
    var targetNumberOfChoices: Int {
        guard TaskNodeType(rawValue: typeIdentifier) == .Checklist && components.count >= 2 else {
            return 0
        }
        
        return NSString(string: components[1]).integerValue
    }
    
    /// The URL for the image
    var imageURL: URL? {
        // Make sure imageFileName is nil, else, return nil
        guard let fileName = imageFileName else {
            return nil
        }
        
        let resURL = treeRootURL.appendingPathComponent("res")
        let imageURLWithoutExtension = resURL.appendingPathComponent(fileName)
        
        // Check for images with supported image formats
        let fileManager = FileManager.default
        let supportedImageFormats = XMLNameInfo.supportedImageFormats
        for format in supportedImageFormats {
            let url = imageURLWithoutExtension.appendingPathExtension(format)
            if fileManager.fileExists(atPath: url.path) {
                return url
            }
        }
        
        return nil
    }
    
    /// The image object
    var image: UIImage? {
        guard let path = imageURL?.path else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
    // MARK: Fetch value of identifier
    
    /// Get the value for an identifier
    func valueOfIdentifer(_ identifier: String) -> String? {
        for component in components {
            if component.hasPrefix(identifier) {
                let endIndex = component.characters.index(component.startIndex, offsetBy: identifier.characters.count)
                return component.substring(from: endIndex)
            }
        }
        return nil
    }
    
    // MARK: Background image
    
    /// The file name for the background image
    var backgroundImageFileName: String {
        let fullIdentifier = "@" + XMLNameInfo.backgroundImageIdentifier + "="
        return valueOfIdentifer(fullIdentifier) ?? "bg"
    }
    
    /// The background image URL
    var backgroundImageURL: URL? {
        let resURL = treeRootURL.appendingPathComponent("res")
        
        // Check for images with supported image formats
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(at: resURL,
            includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants) else {
                return nil
        }
        for content in contents {
            let fileName = content.deletingPathExtension().lastPathComponent
            
            if fileName.compare(backgroundImageFileName, options: .caseInsensitive,
                range: nil, locale: nil) == .orderedSame {
                    return content
            }
        }
        
        return nil
    }
    
    // MARK: Background audio
    
    /// The file name for the background audio
    var backgroundAudioFileName: String? {
        let fullIdentifier = "@" + XMLNameInfo.backgroundAudioIdentifier + "="
        return valueOfIdentifer(fullIdentifier)
    }
    
    /// The URL for the background audio
    var backgroundAudioURL: URL? {
        let audioURL = treeRootURL.appendingPathComponent("audio")
        let targetFileName = backgroundAudioFileName ?? ""
        
        // Finds files in audio/ with file name same to backgroundAudioFileName
        if let contents = try? FileManager.default.contentsOfDirectory(at: audioURL,
            includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants) {
                for content in contents {
                    let fileName = content.deletingPathExtension().lastPathComponent
                    if fileName.compare(targetFileName, options: .caseInsensitive,
                        range: nil, locale: nil) == .orderedSame {
                            return content
                    }
                }
        }
        
        return nil
    }
    
    // MARK: Audio
    
    /// The file name for the audio
    var audioFileName: String? {
        let fullIdentifier = "@" + XMLNameInfo.audioIdentifier + "="
        return valueOfIdentifer(fullIdentifier)
    }
    
    /// The URL for the audio
    var audioURL: URL? {
        let audioURL = treeRootURL.appendingPathComponent("audio")
        let audioLanguageURL = audioURL.appendingPathComponent(language)
        let targetFileName = audioFileName ?? ""
        
        // Find files in audio/{language} with file name same to audioFileName
        if let contents = try? FileManager.default.contentsOfDirectory(at: audioLanguageURL,
            includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants) {
                for content in contents {
                    let fileName = content.deletingPathExtension().lastPathComponent
                    if fileName.compare(targetFileName, options: .caseInsensitive,
                        range: nil, locale: nil) == .orderedSame {
                            return content
                    }
                }
        }
        
        return nil
    }
    
    // MARK: TextField
    
    /// The unit for a text field
    var unit: String? {
        guard components.count >= 2 else {
            return nil
        }
        return components[1]
    }
}
