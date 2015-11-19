//
//  LanguagesTableViewController.swift
//  usbong
//
//  Created by Chris Amanse on 02/10/2015.
//  Copyright 2015 Usbong Social Systems, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

public class LanguagesTableViewController: UITableViewController {
//    public var taskNodeGenerator: UsbongTaskNodeGenerator?
    public var tree: UsbongTree?
    
    public var selectLanguageCompletion: (() -> Void)?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("didPressCancel:"))
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func didPressCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source

    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tree?.availableLanguages.count ?? 0
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if tableView.dequeueReusableCellWithIdentifier("Cell") == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        }
//        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Configure the cell...
        let language = tree?.availableLanguages[indexPath.row]
        cell.textLabel?.text = language
        
        if tree?.currentLanguage == language {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Set current language to selected language
        if let selectedLanguage = tree?.availableLanguages[indexPath.row] {
            tree?.currentLanguage = selectedLanguage
        }
        
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: selectLanguageCompletion)
    }
}
