//
//  Usbong.swift
//  UsbongKit
//
//  Created by Chris Amanse on 27/05/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

public struct Usbong {
    private init() {}
    
    public static func presentViewer(onViewController viewController: UIViewController, withUtreeURL url: NSURL) {
        let storyboard = UIStoryboard(name: "UsbongKit", bundle: NSBundle(forClass: TreeViewController.self))
        
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        let treeVC = navController.topViewController as! TreeViewController
        
        treeVC.treeURL = url
        
        viewController.presentViewController(navController, animated: true, completion: nil)
    }
}