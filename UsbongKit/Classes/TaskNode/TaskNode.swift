//
//  TaskNode.swift
//  usbong
//
//  Created by Chris Amanse on 16/09/2015.
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

public class TaskNode {
    // TODO: Don't put type in TaskNode. This is used only in XML parser, so put it there. (Even for subclasses)
    public class var type: String { return "taskNode" }
    
    public let modules: [TaskNodeModule]
    
    public var backgroundAudioFilePath: String?
    public var audioFilePath: String?
    
    public var targetTransitionName: String?
    public var transitionNamesAndToTaskNodeNames: [String: String] = [String: String]()
    
    public init(modules: [TaskNodeModule]) {
        self.modules = modules
    }
}

extension TaskNode: Equatable {}
public func ==(lhs: TaskNode, rhs: TaskNode) -> Bool {
    return lhs.modules == rhs.modules
}

public class EndStateTaskNode: TaskNode {
    public init(text: String) {
        let textModule = TextTaskNodeModule(text: text)
        super.init(modules: [textModule])
    }
}