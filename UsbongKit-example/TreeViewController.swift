//
//  TreeViewController.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/29/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
@testable import UsbongKit

class TreeViewController: UIViewController {
    
    var treeURL: NSURL?
    var treeRootURL: NSURL?
    
    @IBOutlet weak var nodeView: NodeView!
    @IBOutlet weak var previousNextSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = treeURL {
            if let treeRootURL = UsbongFileManager.defaultManager().unpackTreeToCacheDirectoryWithTreeURL(url) {
                self.treeRootURL = treeRootURL
                print(treeRootURL)
                
                let tree = UsbongTree(treeRootURL: treeRootURL)
                print(tree.taskNodeNames)
                if let startingNode = tree.currentNode {
                    nodeView.node = startingNode
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func didPressExit(sender: AnyObject?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
