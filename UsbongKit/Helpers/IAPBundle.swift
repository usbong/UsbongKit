//
//  IAPBundle.swift
//  UsbongKit
//
//  Created by Chris Amanse on 05/08/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

public struct IAPBundle {
    /// Unique identifier of the bundle (as set in iTunes Connect)
    public var productIdentifier: ProductIdentifier = "com.example.identifier"
    
    /// Languages inside bundle
    public var languages: [String] = ["English", "French"]
    
    public var isPurchased: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(productIdentifier)
    }
    
    /// Create a bundle
    public init(productIdentifier: String, languages: [String]) {
        self.productIdentifier = productIdentifier
        self.languages = languages
    }
}
