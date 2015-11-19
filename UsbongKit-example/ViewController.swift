//
//  ViewController.swift
//  UsbongKit-example
//
//  Created by Chris Amanse on 10/26/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
import UsbongKit

class ViewController: UIViewController {
    var treeZipURL: NSURL?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        print(UsbongFileManager.defaultManager().rootURL)
        
        treeZipURL = NSBundle.mainBundle().URLForResource("Usbong iOS", withExtension: "utree")
        
        if let zipURL = treeZipURL {
            if let treeRootURL = UsbongFileManager.defaultManager().unpackTreeToCacheDirectoryWithTreeURL(zipURL) {
                let tree = UsbongTree(treeRootURL: treeRootURL)
                print("Root: \(tree.treeRootURL)\nXML: \(tree.xmlURL)")
                print("Title: \(tree.title)")
                tree.transitionToNextTaskNode()
                print("TaskNodeNames: \(tree.taskNodeNames)")
                let currentTaskNode = tree.currentTaskNode
                print("TaskNode: \(currentTaskNode)")
                print("TransitionInfo: \(tree.transitionInfo)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressTreeViewer(sender: AnyObject) {
        print("Did Press TreeViewer")
        
//        if let zipURL = treeZipURL {
//            let treeViewer = UsbongTreeViewer(treeZipURL: zipURL)
//            treeViewer.presentTreeViewControllerFromViewController(self, animated: true, completion: nil)
//        }
    }
}

