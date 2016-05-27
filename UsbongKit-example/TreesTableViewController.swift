//
//  TreesTableViewController.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/28/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
import UsbongKit

class TreesTableViewController: UITableViewController {
    var treesURLs: [NSURL] { return UsbongFileManager.defaultManager().treesAtRootURL() }
    
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
        return treesURLs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        var fileName: String? = nil
        if let url = treesURLs[indexPath.row].URLByDeletingPathExtension {
            if let name = url.lastPathComponent {
                if name.stringByReplacingOccurrencesOfString(" ", withString: "").characters.count > 0 {
                    fileName = name
                }
            }
        }
        let finalFileName = fileName == nil ? "Untitled" : fileName
        
        cell.textLabel?.text = finalFileName
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Usbong.presentViewer(onViewController: self, withUtreeURL: treesURLs[indexPath.row])
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "presentTree":
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    if let vc = (segue.destinationViewController as? UINavigationController)?.topViewController as? TreeViewController {
                        vc.treeURL = treesURLs[selectedIndexPath.row]
                    }
                }
            default:
                break
            }
        }
    }
}
