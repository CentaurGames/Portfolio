//
//  ViewController.swift
//  Brimstone
//
//  Created by Priyanjoli Mukherjee & Christopher Brown on 1/20/19.
//  Copyright © 2019 Centaur Games. All rights reserved.
//

import UIKit
import WebKit
import StoreKit

var webView1: WKWebView!

func purchaseGame() {
    webView1.evaluateJavaScript("purchaseGame()") {(res,err) in
        if (err != nil) {
            print(err ?? "null")
        }
    }
}

func closeStoreKit() {
    webView1.evaluateJavaScript("closeStoreKit()") {(res,err) in
        if (err != nil) {
            print(err ?? "null")
        }
    }
}

func onPurchaseSuccess() {
    purchaseGame()
    closeStoreKit()
}

func onPurchaseFail() {
    closeStoreKit()
}

func onPurchaseRestore() {
    purchaseGame()
    closeStoreKit()
}

enum IAPHandlerAlertType{
    case disabled
    case restored
    case purchased
    
    func message() -> String{
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        }
    }
}


class IAPHandler: NSObject {
    static let shared = IAPHandler()
    
    let PURCHASE_ID = "com.centaurgamesonline.Brimstone_BrimstoneLives"
    
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseMyProduct(index: Int){
        if iapProducts.count <= index {
            print(iapProducts.count)
            return
        }
        
        if self.canMakePurchases() {
            let product = iapProducts[index]
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
        } else {
            purchaseStatusBlock?(.disabled)
        }
    }
    
    // MARK: - RESTORE PURCHASE
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(){
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects:
            PURCHASE_ID
        )
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        if (response.products.count > 0) {
            iapProducts = response.products
            for product in iapProducts{
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                let price1Str = numberFormatter.string(from: product.price)
                print(product.localizedDescription + "\nfor just \(price1Str!)")
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        purchaseStatusBlock?(.restored)
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("purchased")
                    onPurchaseSuccess()
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.purchased)
                    break
                    
                case .failed:
                    print("failed")
                    onPurchaseFail()
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    print("restored")
                    onPurchaseRestore()
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }
            }
        }
    }
}



class ViewController: UIViewController, WKUIDelegate {
    var timer: Timer!
    func openStoreKit() {
        IAPHandler.shared.purchaseMyProduct(index: 0)
        //self.closeStoreKit();
    }
    
    @objc func timeInterval() {
        webView1.evaluateJavaScript("isStoreKitOpen()") {(result,error) in
            if (result != nil) {
                if ((result as! String) == "true") {
                    self.openStoreKit()
                    closeStoreKit()
                }
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        
        webView1 = WKWebView(frame: .zero, configuration: webConfiguration)
        //webView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView1.uiDelegate = self
        view = webView1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            if type == .purchased {
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            }
        }
        do {
            guard let filePath = Bundle.main.path(forResource: "index", ofType: "html")
                else {
                    // File Error
                    print ("File reading error")
                    return
            }
            
            let contents = try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            self.view.isOpaque = true
            self.view.backgroundColor = UIColor.black
            webView1.isOpaque = false
            webView1.backgroundColor = UIColor.clear
            self.view.frame = UIScreen.main.bounds
            webView1.frame = UIScreen.main.bounds
            webView1.loadHTMLString(contents as String, baseURL: baseUrl)
            timer = Timer.scheduledTimer(timeInterval: 0.1,target: self,selector: #selector(timeInterval),userInfo: nil, repeats: true)
        }
        catch {
            print ("File HTML error")
        }
    }
}








