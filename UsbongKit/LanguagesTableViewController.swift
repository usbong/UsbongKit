//
//  LanguagesTableViewController.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/31/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

class LanguagesTableViewController: UITableViewController {
    
    var languages: [String] = []
    var selectedLanguage: String = ""
    
    var didSelectLanguageCompletion: ((selectedLanguage: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("dismiss:"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismiss(sender: AnyObject?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let reusedCell = tableView.dequeueReusableCellWithIdentifier("defaultCell") {
            cell = reusedCell
        } else {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "defaultCell")
        }
        
        let language = languages[indexPath.row]
        cell.textLabel?.text = language
        
        if language == selectedLanguage {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedLanguage = languages[indexPath.row]
        
        tableView.reloadData()
        
        dismissViewControllerAnimated(true) {
            self.didSelectLanguageCompletion?(selectedLanguage: self.selectedLanguage)
        }
    }
}
