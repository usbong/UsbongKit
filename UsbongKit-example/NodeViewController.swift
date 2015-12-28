//
//  NodeViewController.swift
//  NodeKit
//
//  Created by Chris Amanse on 12/24/15.
//  Copyright © 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit
import UsbongKit

class NodeViewController: UIViewController {
    var node: Node = TextNode(text: "No Node")
    
    @IBOutlet weak var nodeView: NodeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nodeView.node = node
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

