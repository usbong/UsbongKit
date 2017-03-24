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
    lazy var priceFormatter: NumberFormatter = {
        let pf = NumberFormatter()
        pf.formatterBehavior = .behavior10_4
        pf.numberStyle = .currency
        return pf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "IAPTableViewCell", bundle: Bundle(for: IAPTableViewCell.self)), forCellReuseIdentifier: "itemCell")
        
        // Table view dynamic height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        // Set up a refresh control, call reload to start things up
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
        reload()
        refreshControl?.beginRefreshing()
        
        // Create a Restore Purchases button and hook it up to restoreTapped
        let restoreButton = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
        
        // Subscribe to a notification that fires when a product is purchased.
        NotificationCenter.default.addObserver(self, selector: #selector(productPurchased(_:)), name: NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reload() {
        products = []
        tableView.reloadData()
        
        store.requestProductsWithCompletionHandler { success, products in
            if success {
                self.products = products.sorted { (product1, product2) -> Bool in
                    return product1.price.floatValue < product2.price.floatValue
                }
                
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    // Restore purchases to this device.
    func restoreTapped(_ sender: AnyObject) {
        store.restoreCompletedTransactions()
    }
    
    // When a product is purchased, this notification fires, redraw the correct row
    func productPurchased(_ notification: Notification) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard IAPHelper.canMakePayments() else {
            return 0
        }
        
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! IAPTableViewCell
        
        let product = products[indexPath.row]
        
        priceFormatter.locale = product.priceLocale
        
        cell.itemTitleLabel.text = product.localizedTitle
        cell.itemDescriptionLabel.text = store.languagesFor(product.productIdentifier).joined(separator: ", ")
        cell.itemPriceLabel.text = priceFormatter.string(from: product.price) ?? ""
        
        if store.isProductPurchased(product.productIdentifier) {
            cell.accessoryType = .checkmark
            cell.accessoryView = nil
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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
