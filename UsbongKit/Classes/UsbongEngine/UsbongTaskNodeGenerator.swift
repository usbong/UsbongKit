//
//  UsbongTaskNodeGenerator.swift
//  usbong
//
//  Created by Chris Amanse on 01/10/2015.
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

public protocol UsbongTaskNodeGenerator {
    var title: String { get }
    var taskNodesCount: Int { get }
    var currentLanguage: String { get set }
    var currentLanguageCode: String { get }
    var availableLanguages: [String] { get }
    
    var previousTaskNode: TaskNode? { get }
    var currentTaskNode: TaskNode? { get }
    var nextTaskNode: TaskNode? { get }
    
    func transitionToNextTaskNode() -> Bool
    func transitionToPreviousTaskNode() -> Bool
}