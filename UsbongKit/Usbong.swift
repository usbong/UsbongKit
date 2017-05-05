//
//  Usbong.swift
//  UsbongKit
//
//  Created by Chris Amanse on 27/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

/// Usbong is a collection of functions to manage utree files
public struct Usbong {
    fileprivate init() {}
    
    /**
     Read utree file and present viewer
     
     - parameters:
       - viewController: The parent view controller for the to be presented viewer
       - url: URL for the utree file
    */
    public static func presentViewer(onViewController viewController: UIViewController, withUtreeURL url: URL, andData data: UsbongTreeData = UsbongTreeData()) {
        let storyboard = UIStoryboard(name: "UsbongKit", bundle: Bundle(for: TreeViewController.self))
        
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        let treeVC = navController.topViewController as! TreeViewController
        
        treeVC.treeURL = url
        treeVC.store = IAPHelper(bundles: data.bundles)
        
        viewController.present(navController, animated: true, completion: nil)
    }
}

public struct UsbongTreeData {
    public var bundles: [IAPBundle] = []
    
    public init() {}
    
    public init(bundles: [IAPBundle]) {
        self.bundles = bundles
    }
}
