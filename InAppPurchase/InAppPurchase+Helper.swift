import Foundation
import StoreKit

public typealias ProductIdentifier = String

public typealias ProductsRequestCompletionHandler = (_ products: [SKProduct]?) -> ()

open class InAppPurchaseHelper : NSObject  {

    static let PurchaseNotification = Notification.Name("PurchaseNotification")

    fileprivate let productIdentifiers: Set<ProductIdentifier>
    
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
    
    fileprivate var productsRequest: SKProductsRequest?
    
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?

    fileprivate var skPaymentQueue: SKPaymentQueue!
    
    fileprivate var userDefaults: MOUserDefaults!
    
    fileprivate var paymentsService: PaymentsService!
    
    init(userDefaults: MOUserDefaults, paymentsService: PaymentsService) {
        
        self.productIdentifiers = Products.productIdentifiers
        
        self.userDefaults = userDefaults
        
        self.paymentsService = paymentsService
        
        self.skPaymentQueue = SKPaymentQueue.default()
        
        super.init()
    
        self.checkPurchasedProducts()

        self.skPaymentQueue.add(self)

    }
    
    deinit {
        
        self.skPaymentQueue.remove(self)
        
    }
    
    private func checkPurchasedProducts() {
        
        for productIdentifier in self.productIdentifiers {
            
            if let purchased = self.userDefaults.boolForKey(productIdentifier), purchased {
                
                self.purchasedProductIdentifiers.insert(productIdentifier)
                
                print("Previously purchased: \(productIdentifier)")
                
            } else {
                
                print("Not purchased: \(productIdentifier)")
                
            }
            
        }
        
    }

    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        
        self.productsRequestCompletionHandler = completionHandler

        if self.canMakePayments() {
            
            self.productsRequest?.cancel()
            
            self.productsRequest = SKProductsRequest(productIdentifiers: self.productIdentifiers)
            
            print(productIdentifiers)
            
            self.productsRequest?.delegate = self
            
            self.productsRequest?.start()
            
        } else {
            
            self.productsRequestCompletionHandler?(nil)
            
        }
        
    }
    
    public func buyProduct(_ product: SKProduct) {
        
        print("Buying \(product.productIdentifier)...")
        
        let payment = SKPayment(product: product)
        
        self.skPaymentQueue.add(payment)
        
    }
    
    private func canMakePayments() -> Bool {
        
        return SKPaymentQueue.canMakePayments()
        
    }
    
    public func restorePurchases() {
        
        self.skPaymentQueue.restoreCompletedTransactions()
        
    }
    
}

extension InAppPurchaseHelper: SKProductsRequestDelegate {

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        print("Loaded list of products...")
        
        print("Invalid: \(response.invalidProductIdentifiers)")
        
        print("Valid: \(response.products)")
        
        let products = response.products
        
        self.productsRequestCompletionHandler?(products)
        
        self.clearRequestAndHandler()
        
        for p in products {
        
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
    
        }
    
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        
        print("Failed to load list of products.")
        
        print("Error: \(error.localizedDescription)")
        
        self.productsRequestCompletionHandler?(nil)
        
        self.clearRequestAndHandler()
    
    }
    
    private func clearRequestAndHandler() {
        
        self.productsRequest = nil
    
        self.productsRequestCompletionHandler = nil
    
    }

}

extension InAppPurchaseHelper: SKPaymentTransactionObserver {
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        if queue.transactions.isEmpty {
            
            self.requestProducts(completionHandler: { products in
                
                if let product = products?.first {
                    
                    self.buyProduct(product)
                    
                } else {
                    
                    NotificationCenter.default.post(name: InAppPurchaseHelper.PurchaseNotification, object: nil, userInfo: [k_has_finished: false])
         
                }
                
            })
            
        }  
        
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
        
            switch transaction.transactionState {
            
            case .purchased:
            
                self.complete(transaction: transaction)
                
                break
            
            case .failed:
            
                self.fail(transaction: transaction)
                
                break
            
            case .restored:
            
                self.restore(transaction: transaction)
                
                break
            
            case .deferred: break
            case .purchasing: break
            
            }
            
        }
        
    }
    
    private func complete(transaction: SKPaymentTransaction) {
    
        print("complete...")
        
        self.deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        
        self.skPaymentQueue.finishTransaction(transaction)
    
    }
    
    private func restore(transaction: SKPaymentTransaction) {
    
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        
        self.deliverPurchaseNotificationFor(identifier: productIdentifier)
        
        self.skPaymentQueue.finishTransaction(transaction)
    
    }
    
    private func fail(transaction: SKPaymentTransaction) {
    
        print("fail...")
        
        if let transactionError = transaction.error {
        
            if transactionError._code != SKError.paymentCancelled.rawValue {
            
                print("Transaction Error: \(transactionError.localizedDescription)")
            
            }
        
        }
        
        self.skPaymentQueue.finishTransaction(transaction)
    
        NotificationCenter.default.post(name: InAppPurchaseHelper.PurchaseNotification, object: nil, userInfo: [k_has_finished: false])
                
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
       
        guard let identifier = identifier else { return }

        self.purchasedProductIdentifiers.insert(identifier)
 
        NotificationCenter.default.post(name: InAppPurchaseHelper.PurchaseNotification, object: identifier, userInfo: [k_has_finished: true])
        
    }
    
    public func productBought() {
        
        if let identifier = self.purchasedProductIdentifiers.first {
            
            self.userDefaults.setBool(true, forKey: identifier)
            
//            _ = self.userDefaults.synchronize()
            
        }

    }
    
    public func validateReceipt(id: String, parameters: String, completion: @escaping ErrorCompletion) {
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return }
        
        do {
            
            let receipt = try Data(contentsOf: receiptURL).base64
            
            self.paymentsService.validateReceipt(id: id, parameters: parameters, receipt: receipt, completion: completion)
            
        } catch let error {
            
            completion(error)
        
        }
        
    }
    
}
