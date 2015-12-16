//
//  ClassificationTaskNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/16/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

public class ClassificationTaskNode: TaskNode {
    public var indexOffset: Int = 1
    
    public init(text: String, tasks: [LinkTaskNodeTask]) {
        var currentModules = [TaskNodeModule]()
        currentModules.append(TextTaskNodeModule(text: text))
        
        let count = tasks.count + indexOffset
        for currentIndex in indexOffset..<count {
            currentModules.append(ClassificationTaskNodeModule(task: tasks[currentIndex - indexOffset], index: currentIndex))
        }
        
        super.init(modules: currentModules)
    }
}

public class ClassificationTaskNodeModule: TaskNodeModule {
    public init(task: LinkTaskNodeTask, index: Int) {
        super.init(content: ["taskValue": NSString(string: "\(index)) \(task.value)"), "taskIdentifier": NSString(string: task.identifier)])
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

extension ClassificationTaskNodeModule: SpeakableModule {
    public var speakableText: String {
        return taskValue
    }
}