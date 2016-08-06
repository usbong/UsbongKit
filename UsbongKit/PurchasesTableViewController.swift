//
//  PurchasesTableViewController.swift
//  UsbongKit
//
//  Created by Chris Amanse on 05/08/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation
import StoreKit

class PurchasesTableViewController: UITableViewController {
    var store: IAPHelper = IAPHelper(bundles: [])
    
    var products: [SKProduct] = []
    
    // priceFormatter is used to show proper, localized currency
    lazy var priceFormatter: NSNumberFormatter = {
        let pf = NSNumberFormatter()
        pf.formatterBehavior = .Behavior10_4
        pf.numberStyle = .CurrencyStyle
        return pf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "IAPTableViewCell", bundle: NSBundle(forClass: IAPTableViewCell.self)), forCellReuseIdentifier: "itemCell")
        
        // Table view dynamic height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        // Set up a refresh control, call reload to start things up
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reload), forControlEvents: .ValueChanged)
        reload()
        refreshControl?.beginRefreshing()
        
        // Create a Restore Purchases button and hook it up to restoreTapped
        let restoreButton = UIBarButtonItem(title: "Restore", style: .Plain, target: self, action: #selector(restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
        
        // Subscribe to a notification that fires when a product is purchased.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(productPurchased(_:)), name: IAPHelperProductPurchasedNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func reload() {
        products = []
        tableView.reloadData()
        
        store.requestProductsWithCompletionHandler { success, products in
            if success {
                self.products = products.sort { (product1, product2) -> Bool in
                    return product1.price.floatValue < product2.price.floatValue
                }
                
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    // Restore purchases to this device.
    func restoreTapped(sender: AnyObject) {
        store.restoreCompletedTransactions()
    }
    
    // When a product is purchased, this notification fires, redraw the correct row
    func productPurchased(notification: NSNotification) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard IAPHelper.canMakePayments() else {
            return 0
        }
        
        return products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as! IAPTableViewCell
        
        let product = products[indexPath.row]
        
        priceFormatter.locale = product.priceLocale
        
        cell.itemTitleLabel.text = product.localizedTitle
        cell.itemDescriptionLabel.text = store.languagesFor(product.productIdentifier).joinWithSeparator(", ")
        cell.itemPriceLabel.text = priceFormatter.stringFromNumber(product.price) ?? ""
        
        if store.isProductPurchased(product.productIdentifier) {
            cell.accessoryType = .Checkmark
            cell.accessoryView = nil
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let product = products[indexPath.row]
        
        // Purchase product only when not yet purchased
        if !store.isProductPurchased(product.productIdentifier) {
            // Purchase product
            store.purchaseProduct(product)
        } else {
            print("Product already purchased")
        }
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
