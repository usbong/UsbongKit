//
//  LinkTaskNode.swift
//  UsbongKit
//
//  Created by Joe Amanse on 18/11/2015.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

public struct LinkTaskNodeTask {
    public let identifier: String
    public let value: String
    
    public init(identifier: String, value: String) {
        self.identifier = identifier
        self.value = value
    }
}

public class LinkTaskNode: TaskNode {
    public var indexOffset: Int = 1
    public var currentSelectedIndex: Int = -1 // -1 means none
    public var trueIndex: Int {
        if currentSelectedIndex >= 0 {
            return indexOffset + currentSelectedIndex
        } else {
            return -1
        }
    }
    public var currentSelectedModule: LinkTaskNodeModule? {
        let index = trueIndex
        if index >= 0 && index < modules.count {
            return modules[index] as? LinkTaskNodeModule
        }
        return nil
    }
    
    public init(text: String, tasks: [LinkTaskNodeTask]) {
        var currentModules = [TaskNodeModule]()
        currentModules.append(TextTaskNodeModule(text: text))
        
        // Test tasks
        for task in tasks {
            currentModules.append(LinkTaskNodeModule(task: task))
        }
        
        super.init(modules: currentModules)
    }
}

public class LinkTaskNodeModule: TaskNodeModule {
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