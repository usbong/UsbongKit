//
//  LanguagesTableViewController.swift
//  UsbongKit
//
//  Created by Chris Amanse on 12/31/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

class LanguagesTableViewController: UITableViewController {
    var store: IAPHelper = IAPHelper(bundles: []) {
        didSet {
            if isViewLoaded() {
                tableView.reloadData()
            }
        }
    }
    
    var languages: [String] = [] {
        didSet {
            if isViewLoaded() {
                tableView.reloadData()
            }
        }
    }
    var selectedLanguage = ""
    
    var didSelectLanguageCompletion: ((selectedLanguage: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(dismiss(_:)))
        
        // Subscribe to a notification that fires when a product is purchased.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(productPurchased(_:)), name: IAPHelperProductPurchasedNotification, object: nil)
    }
    
    func dismiss(sender: AnyObject?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func productPurchased(sender: AnyObject?) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultCell", forIndexPath: indexPath)
        
        let language = languages[indexPath.row]
        cell.textLabel?.text = language
        
        // If purchased, set text color to black
        if store.isLanguagePurchased(language) {
            cell.textLabel?.textColor = .blackColor()
        } else {
            cell.textLabel?.textColor = .lightGrayColor()
        }
        
        if language == selectedLanguage {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let targetLanguage = languages[indexPath.row]
        
        // Show purchase screen if unpurchased
        guard store.isLanguagePurchased(targetLanguage) else {
            print("Language is for purchase!")
            
            performSegueWithIdentifier("showProducts", sender: tableView)
            
            return
        }
        
        // Pass through if not unpurchased
//        guard !IAPProducts.isUnpurchasedLanguage(targetLanguage) else {
//            // Unavailable
//            print("Language is for purchase!")
//            
//            performSegueWithIdentifier("showProducts", sender: tableView)
//            
//            return
//        }
        
        selectedLanguage = targetLanguage
        
        tableView.reloadData()
        
        dismissViewControllerAnimated(true) {
            self.didSelectLanguageCompletion?(selectedLanguage: targetLanguage)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier ?? "" {
        case "showProducts":
            let destinationViewController = segue.destinationViewController as! PurchasesTableViewController
            
            destinationViewController.store = store
        default:
            break
        }
    }
}
