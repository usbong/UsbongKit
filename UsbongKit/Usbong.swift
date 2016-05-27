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
    private init() {}
    
    /**
     Read utree file and present viewer
     
     - parameters:
       - viewController: The parent view controller for the to be presented viewer
       - url: URL for the utree file
    */
    public static func presentViewer(onViewController viewController: UIViewController, withUtreeURL url: NSURL) {
        let storyboard = UIStoryboard(name: "UsbongKit", bundle: NSBundle(forClass: TreeViewController.self))
        
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        let treeVC = navController.topViewController as! TreeViewController
        
        treeVC.treeURL = url
        
        viewController.presentViewController(navController, animated: true, completion: nil)
    }
}