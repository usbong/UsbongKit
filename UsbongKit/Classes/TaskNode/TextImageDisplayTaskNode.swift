//
//  TextImageDisplayNode.swift
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

public class TextImageDisplayTaskNode: TaskNode {
    override public class var type: String { return "textImageDisplay" }
    
    public init(text: String, imageFilePath: String) {
        let textModule = TextTaskNodeModule(text: text)
        let imageModule = ImageTaskNodeModule(imageFilePath: imageFilePath)
        super.init(modules: [textModule, imageModule])
    }
}