//
//  LinkTaskNode.swift
//  UsbongKit
//
//  Created by Joe Amanse on 18/11/2015.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

public class LinkTaskNode: TaskNode {
    public init(text: String, tasks: [String]) {
        let textModule = TextTaskNodeModule(text: text)
        
        super.init(modules: [textModule])
    }
}