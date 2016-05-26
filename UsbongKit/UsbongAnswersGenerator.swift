//
//  UsbongAnswersGenerator.swift
//  UsbongKit
//
//  Created by Joe Amanse on 12/03/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

/// Generate answers based on `UsbongNodeState`s
public protocol UsbongAnswersGenerator {
    associatedtype OutputType
    
    var states: [UsbongNodeState] { get }
    
    /// Create an instance of `UsbongAnswersGenerator` type
    init(states: [UsbongNodeState])
    
    /// Generate output of type `OutputType`
    @warn_unused_result
    func generateOutput() -> OutputType
    
    /// Generate output of type `NSData`
    @warn_unused_result
    func generateOutputData() -> NSData?
}

extension UsbongAnswersGenerator {
    func generateOutputData() -> NSData? {
        return nil
    }
}

/// Generate answers to default CSV format
public class UsbongAnswersGeneratorDefaultCSVString: UsbongAnswersGenerator {
    /// A collection of `UsbongNodeState`s that the output will be based upon
    public let states: [UsbongNodeState]
    
    /// Create an instance of `UsbongAnswersGeneratorDefaultCSVString`
    public required init(states: [UsbongNodeState]) {
        self.states = states
    }
    
    /// Generate an output of type `String`
    public func generateOutput() -> String {
        var finalString = ""
        
        for state in states {
            let transitionName = state.transitionName
            var currentEntry = "";
            
            // Get first character of transition name or index
            let firstCharacter: String
            if let taskNodeType = state.taskNodeType {
                switch taskNodeType {
                case .RadioButtons, .Link:
                    // Use selected index for first character
                    let selectedIndex = (state.fields["selectedIndices"] as? [Int])?.first ?? 0
                    
                    firstCharacter = String(selectedIndex)
                default:
                    // By default, use first character of transition name
                    firstCharacter = String(transitionName.characters.first ?? Character(""))
                }
            } else {
                // By default, use first character of transition name
                firstCharacter = String(transitionName.characters.first ?? Character(""))
            }
            
            // Add first character to current entry
            currentEntry += firstCharacter
            
            // Get additional fields for current entry
            if let taskNodeType = state.taskNodeType {
                switch taskNodeType {
                case .TextField, .TextFieldNumerical, .TextFieldWithUnit, .TextFieldWithAnswer,
                .TextArea, .TextAreaWithAnswer:
                    // Get text input field
                    let textInput = (state.fields["textInput"] as? String) ?? ""
                    
                    currentEntry += "," + textInput
                case .Date:
                    let date = (state.fields["date"] as? NSDate) ?? NSDate()
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    
                    currentEntry += "," + dateFormatter.stringFromDate(date)
                default:
                    break
                }
            }
            
            // Add entry in final string
            finalString += currentEntry + ";"
        }
        
        return finalString
    }
    
    /// Generate an output of type `NSData`
    public func generateOutputData() -> NSData? {
        let string = generateOutput()
        
        return string.dataUsingEncoding(NSUTF8StringEncoding)
    }
}

// Extend functionality of UsbongTree
public extension UsbongTree {
    /**
     Generate output of current `UsbongNodeState`s
     
     - parameter generatorType: Type of an `UsbongAnswersGenerator`
     
     - returns: Generated answers of type `OutputType`
    */
    func generateOutput<T: UsbongAnswersGenerator>(generatorType: T.Type) -> T.OutputType {
        return generatorType.init(states: usbongNodeStates).generateOutput()
    }
    
    /**
     Generate output of current `UsbongNodeState`s
     
     - parameter generatorType: Type of an `UsbongAnswersGenerator`
     
     - returns: Generated answers of type `NSData`
     */
    func generateOutputData<T: UsbongAnswersGenerator>(generatorType: T.Type) -> NSData? {
        return generatorType.init(states: usbongNodeStates).generateOutputData()
    }
    
    /**
     Write output of current `UsbongNodeState`s to file
     
     - parameters:
       - generatorType: Type of an `UsbongAnswersGenerator`
       - path: Where the output will be written
       - completion: Handler for when the writing completes, whether successful or not
    */
    func writeOutputData<T: UsbongAnswersGenerator>(generatorType: T.Type, toFilePath path: String, completion: ((success: Bool) -> Void)?) {
        guard let data = generateOutputData(generatorType) else {
            completion?(success: false)
            return
        }
        
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue) {
            let writeSuccess = NSFileManager.defaultManager().createFileAtPath(path, contents: data, attributes: nil)
            dispatch_async(dispatch_get_main_queue()) {
                completion?(success: writeSuccess)
            }
        }
    }
    
    /**
     Save output of current `UsbongNodeState`s to `Documents/Answers/{timeStamp}.csv`
     
     - parameters:
       - generatorType: Type of an `UsbongAnswersGenerator`
       - completion: Handler for when the writing completes, whether successful or not
    */
    func saveOutputData<T: UsbongAnswersGenerator>(generatorType: T.Type, completion: ((success: Bool, filePath: String) -> Void)?) {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsURL = urls[urls.count - 1]
        let answersURL = documentsURL.URLByAppendingPathComponent("Answers", isDirectory: true)
        
        var isDirectory: ObjCBool = false
        let fileExists = fileManager.fileExistsAtPath(answersURL.path ?? "", isDirectory: &isDirectory)
        
        // If Answers directory doesn't exist (or it exists but not a directory), create directory
        if !fileExists || (fileExists && !isDirectory.boolValue) {
            do {
                try fileManager.createDirectoryAtURL(answersURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create Answers directory")
            }
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let fileName = dateFormatter.stringFromDate(NSDate()) + ".csv"
        
        guard let targetFilePath = answersURL.URLByAppendingPathComponent(fileName).path else {
            return
        }
        
        writeOutputData(generatorType, toFilePath: targetFilePath) { (success) -> Void in
            completion?(success: success, filePath: targetFilePath)
        }
    }
}
