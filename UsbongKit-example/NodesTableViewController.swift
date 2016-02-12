//
//  NodesTableViewController.swift
//  NodeKit
//
//  Created by Chris Amanse on 12/26/15.
//  Copyright © 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit
import UsbongKit

class NodesTableViewController: UITableViewController {
    let nodes: [Node] = [
        TextNode(text: "This is a TextNode"),
        ImageNode(image: UIImage(named: "Test")),
        TextImageNode(text: "This is a TextImageNode", image: UIImage(named: "Test")),
        ImageTextNode(image: UIImage(named: "Test"), text: "This is an ImageTextNode"),
        RadioButtonsNode(text: "This is a RadioButtonsNode", options: ["Option 1", "Option 2", "Option 3"]),
        ChecklistNode(text: "This is a ChecklistNode", options: ["Option 1", "Option 2", "Option 3"]),
        ClassificationNode(text: "This is a ClassificationNode", list: ["1) Item 1", "2) Item 2", "3) Item 3", "4) Item 4"]),
        TextFieldNode(text: "This is a TextFieldNode"),
        TextFieldNumericalNode(text: "This is a TextFieldNumericalNode"),
        TextFieldWithUnitNode(text: "This is a TextFieldWithUnitNode", unit: "meter(s)"),
        TextAreaNode(text: "This is a TextAreaNode")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = titleForNode(nodes[indexPath.row])
        
        return cell
    }
    
    func titleForNode(node: Node) -> String {
        return String(node.dynamicType)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "showNode":
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                let selectedNode = nodes[selectedIndexPath.row]
                
                if let vc = segue.destinationViewController as? NodeViewController {
                    vc.navigationItem.title = titleForNode(selectedNode)
                    vc.node = selectedNode
                }
            }
        default:
            break
        }
    }
}
