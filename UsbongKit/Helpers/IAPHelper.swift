//
//  IAPHelper.swift
//  UsbongKit
//
//  Created by Chris Amanse on 05/08/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation
import StoreKit

/// Notification that is generated when a product is purchased.
public let IAPHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"

/// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

/// Completion handler called when products are fetched.
public typealias RequestProductsCompletionHandler = (success: Bool, products: [SKProduct]) -> ()


/// A Helper class for In-App-Purchases, it can fetch products, tell you if a product has been purchased,
/// purchase products, and restore purchases.  Uses NSUserDefaults to cache if a product has been purchased.
public class IAPHelper : NSObject  {
    // Used to keep track of the possible products and which ones have been purchased.
    private let bundles: [IAPBundle]
    
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers = Set<ProductIdentifier>()
    
    // Used by SKProductsRequestDelegate
    private var productsRequest: SKProductsRequest?
    private var completionHandler: RequestProductsCompletionHandler?
    
    /// MARK: - User facing API
    
    /// Initialize the helper.  Pass in the Bundles supported by the app.
    public init(bundles: [IAPBundle]) {
        self.bundles = bundles
        productIdentifiers = Set(bundles.map { $0.productIdentifier })
        
        // Log products if purchased or not
        for bundle in bundles {
            if bundle.isPurchased {
                purchasedProductIdentifiers.insert(bundle.productIdentifier)
                print("Previously purchased: \(bundle.productIdentifier)")
            } else {
                print("Not yet purchased: \(bundle.productIdentifier)")
            }
        }
        
        super.init()
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    deinit {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    /// Gets the list of SKProducts from the Apple server calls the handler with the list of products.
    public func requestProductsWithCompletionHandler(handler: RequestProductsCompletionHandler) {
        completionHandler = handler
        
        let productIdentifiers = bundles.map { $0.productIdentifier }
        
        productsRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    /// Initiates purchase of a product.
    public func purchaseProduct(product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    /// Given the product identifier, returns true if that product has been purchased.
    public func isProductPurchased(productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    /// If the state of whether purchases have been made is lost  (e.g. the
    /// user deletes and reinstalls the app) this will recover the purchases.
    public func restoreCompletedTransactions() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

extension IAPHelper {
    func productIdentifierFor(language: String) -> ProductIdentifier? {
        for bundle in bundles {
            if bundle.languages.contains(language) {
                return bundle.productIdentifier
            }
        }
        
        return nil
    }
    
    func languagesFor(productIdentifier: ProductIdentifier) -> [String] {
        for bundle in bundles {
            if bundle.productIdentifier == productIdentifier {
                return bundle.languages
            }
        }
        
        return []
    }
    
    func isLanguagePurchased(language: String) -> Bool {
        guard let identifier = productIdentifierFor(language) else {
            // If it doesn't have a product identifier, it means it's purchased (or doesn't need to be purchased)
            return true
        }
        
        // If product with that identifier is purchased, language is also purchased
        return isProductPurchased(identifier)
    }
}

extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        // debug printing
        for product in products {
            print("Found product:\n  - id: \(product.productIdentifier)\n  - name: \(product.localizedTitle)\n  - price: \(product.price.floatValue)")
        }
        
        completionHandler?(success: true, products: products)
        clearRequest()
    }
    
    public func request(request: SKRequest, didFailWithError error: NSError) {
        print("Failed to load list of products.")
        print("Error: \(error)")
        clearRequest()
    }
    
    private func clearRequest() {
        productsRequest = nil
        completionHandler = nil
    }
}

extension IAPHelper: SKPaymentTransactionObserver {
    /// This is a function called by the payment queue, not to be called directly.
    /// For each transaction act accordingly, save in the purchased cache, issue notifications,
    /// mark the transaction as complete.
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .Purchased:
                completeTransaction(transaction)
                break
            case .Failed:
                failedTransaction(transaction)
                break
            case .Restored:
                restoreTransaction(transaction)
                break
            case .Deferred:
                break
            case .Purchasing:
                break
            }
        }
    }
    
    private func completeTransaction(transaction: SKPaymentTransaction) {
        print("completeTransaction...")
        provideContentForProductIdentifier(transaction.payment.productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        let productIdentifier = transaction.originalTransaction!.payment.productIdentifier
        print("restoreTransaction... \(productIdentifier)")
        provideContentForProductIdentifier(productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    // Helper: Saves the fact that the product has been purchased and posts a notification.
    private func provideContentForProductIdentifier(productIdentifier: String) {
        purchasedProductIdentifiers.insert(productIdentifier)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(IAPHelperProductPurchasedNotification, object: productIdentifier)
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction) {
        print("failedTransaction...")
        if transaction.error!.code == SKErrorCode.PaymentCancelled.rawValue {
            print("Transaction error: \(transaction.error!.localizedDescription)")
        }
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
}

