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
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    var languages: [String] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    var selectedLanguage = ""
    
    var didSelectLanguageCompletion: ((_ selectedLanguage: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss(_:)))
        
        // Subscribe to a notification that fires when a product is purchased.
        NotificationCenter.default.addObserver(self, selector: #selector(productPurchased(_:)), name: NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification), object: nil)
    }
    
    func dismiss(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func productPurchased(_ sender: AnyObject?) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        
        let language = languages[indexPath.row]
        cell.textLabel?.text = language
        
        // If purchased, set text color to black
        if store.isLanguagePurchased(language) {
            cell.textLabel?.textColor = .black
        } else {
            cell.textLabel?.textColor = .lightGray
        }
        
        if language == selectedLanguage {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetLanguage = languages[indexPath.row]
        
        // Show purchase screen if unpurchased
        guard store.isLanguagePurchased(targetLanguage) else {
            print("Language is for purchase!")
            
            performSegue(withIdentifier: "showProducts", sender: tableView)
            
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
        
        self.dismiss(animated: true) {
            self.didSelectLanguageCompletion?(targetLanguage)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "showProducts":
            let destinationViewController = segue.destination as! PurchasesTableViewController
            
            destinationViewController.store = store
        default:
            break
        }
    }
}
