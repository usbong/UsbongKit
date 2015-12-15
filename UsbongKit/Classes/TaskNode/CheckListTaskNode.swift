//
//  CheckListTaskNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/15/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

public class CheckListTaskNode: TaskNode {
    public var indexOffset: Int = 1
    public var targetNumberOfChoices = 0
    public private(set) var selectedIndices: [Int] = []
    public var trueSelectedIndices: [Int] {
        var indices: [Int] = []
        
        for index in selectedIndices {
            if index >= 0 {
                indices.append(indexOffset + index)
            }
        }
        
        return indices
    }
    
    public func selectIndex(index: Int) {
        // Make sure index isn't stored already
        guard !selectedIndices.contains(index) else {
            return
        }
        
        selectedIndices.append(index)
    }
    public func deselectIndex(index: Int) {
        // Remove index (even duplicates)
        while let indexOfIndex = selectedIndices.indexOf(index) {
            selectedIndices.removeAtIndex(indexOfIndex)
        }
    }
    
    public init(text: String, tasks: [LinkTaskNodeTask]) {
        var currentModules = [TaskNodeModule]()
        currentModules.append(TextTaskNodeModule(text: text))
        
        for task in tasks {
            currentModules.append(LinkTaskNodeModule(task: task))
        }
        
        super.init(modules: currentModules)
    }
}

public class CheckListTaskNodeModule: TaskNodeModule {
    public init(task: LinkTaskNodeTask) {
        super.init(content: ["taskValue": NSString(string: task.value), "taskIdentifier": NSString(string: task.identifier)])
    }
    
    public var taskValue: String {
        get {
            return (content["taskValue"] as? NSString ?? "") as String
        }
        set {
            content["taskValue"] = NSString(string: newValue)
        }
    }
    
    public var taskIdentifier: String {
        get {
            return (content["taskIdentifier"] as? NSString ?? "") as String
        }
        set {
            content["taskIdentifier"] = NSString(string: newValue)
        }
    }
}

extension CheckListTaskNodeModule: SpeakableModule {
    public var speakableText: String {
        return taskValue
    }
}