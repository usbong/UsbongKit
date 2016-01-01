//
//  SpeakableTextTypeModule.swift
//  UsbongKit
//
//  Created by Chris Amanse on 1/1/16.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

public protocol SpeakableTextTypeModule {
    var speakableTexts: [String] { get }
}

extension TextModule: SpeakableTextTypeModule {
    public var speakableTexts: [String] {
        return [text]
    }
}

extension ListModule: SpeakableTextTypeModule {
    public var speakableTexts: [String] {
        return options
    }
}
