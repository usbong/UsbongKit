//
//  ReadableTextTypeNode.swift
//  UsbongKit
//
//  Created by Chris Amanse on 1/1/16.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

// MARK: - ReadableTextTypeNode
public protocol ReadableTextTypeNode {
    var readableText: String { get }
}

// MARK: - TextNode
extension TextNode: ReadableTextTypeNode {
    public var readableText: String {
        return (modules.first as! TextModule).text
    }
}