//
//  AutoPlayableTree.swift
//  UsbongKit
//
//  Created by Chris Amanse on 3/26/16.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation
import AVFoundation

public protocol AutoPlayableTree: PlayableTree, VoiceOverCoordinatorDelegate {
    var autoPlay: Bool { get set }
    
    var voiceOverCoordinator: VoiceOverCoordinator { get set }
}

public extension AutoPlayableTree {
    var autoPlay: Bool {
        get {
            // Default to true if not yet set
            let standardUserDefaults = NSUserDefaults.standardUserDefaults()
            if standardUserDefaults.objectForKey("UsbongKit.AutoPlayableTree.autoPlay") == nil {
                standardUserDefaults.setBool(false, forKey: "UsbongKit.AutoPlayableTree.autoPlay")
            }
            return standardUserDefaults.boolForKey("UsbongKit.AutoPlayableTree.autoPlay")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "UsbongKit.AutoPlayableTree.autoPlay")
        }
    }
}
