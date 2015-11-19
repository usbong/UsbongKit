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
    public var currentSelectedIndex: Int = -1 // -1 means none
    
    public init(text: String, tasks: [LinkTaskNodeTask]) {
        var currentModules = [TaskNodeModule]()
        currentModules.append(TextTaskNodeModule(text: text))
        
        // Test tasks
        for task in tasks {
            currentModules.append(TextTaskNodeModule(text: task.value))
        }
        
        super.init(modules: currentModules)
    }
}