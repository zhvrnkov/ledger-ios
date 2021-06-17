//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit
import KeychainAccess
import Kronos

public final class Ledger {
    public enum Error: Swift.Error {
        case noProduct
    }

    private enum Constants {
        static let keychainService: String = "ledger"
        static let keychainReceiptKey: String = "receipt"
    }

    public private(set) static var receipt: Receipt = fetchCachedReceipt() {
        didSet {
            if let data = try? JSONEncoder().encode(receipt) {
                try? keychain.set(data, key: Constants.keychainReceiptKey)
            }
        }
    }

    public static var referenceDate: Date {
        return Clock.now ?? Date()
    }

    private static var sharedSecret: String = "---" // "be5dce7c61f7401591767e58dc171d64"
    private static var productCache: NSCache<NSString, Product> = .init()
    private static var keychain: Keychain = .init(service: Constants.keychainService)

    public static func start(sharedSecret: String) {
        self.sharedSecret = sharedSecret
        Clock.sync()
        SwiftyStoreKit.completeTransactions(atomically: false) { (purchases: [Purchase]) in
            validateReceipt { (_: Receipt) in
                for purchase in purchases where purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
        }

        validateReceipt { (receipt: Receipt) in
            print("[II] Receipt validated")
            print(receipt)
        }
    }

    public static func fetchProducts(withIdentifiers identifiers: [String], completion: @escaping ([String: Product]) -> Void = { _ in }) {
        var result: [String: Product] = [:]
        var pendingIdentifiers: [String] = []
        for identifier in identifiers {
            let nsIdentifier = identifier as NSString
            if let product = productCache.object(forKey: nsIdentifier) {
                result[identifier] = product
            }
            else {
                pendingIdentifiers.append(identifier)
            }
        }

        guard pendingIdentifiers.isEmpty == false else {
            return completion(result)
        }

        SwiftyStoreKit.retrieveProductsInfo(.init(pendingIdentifiers)) { (retrieveResults: RetrieveResults) in
            for storeProduct in retrieveResults.retrievedProducts {
                let product = Product(storeProduct: storeProduct)
                let nsIdentifier = product.identifier as NSString
                productCache.setObject(product, forKey: nsIdentifier)
                result[product.identifier] = product
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    public static func purchaseProduct(withIdentifier identifier: String,
                                       success: @escaping (Product) -> Void,
                                       failure: @escaping (Swift.Error) -> Void) {
        fetchProducts(withIdentifiers: [identifier]) { (result: [String: Product]) in
            guard let product = result[identifier] else {
                return failure(Error.noProduct)
            }

            SwiftyStoreKit.purchaseProduct(product.storeProduct, atomically: false) { (result: PurchaseResult) in
                switch result {
                case let .success(details):
                    validateReceipt { (_: Receipt) in
                        if details.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(details.transaction)
                        }
                        DispatchQueue.main.async {
                            success(product)
                        }
                    } failure: { (error: Swift.Error) in
                        DispatchQueue.main.async {
                            failure(error)
                        }
                    }
                case let .error(error):
                    DispatchQueue.main.async {
                        failure(error)
                    }
                }
            }
        }
    }

    public static func isProductPurchased(identifier: String) -> Bool {
        return receipt.purchases[identifier] != nil
    }

    public static func isAnyProductPurchased() -> Bool {
        return receipt.purchases.isEmpty == false
    }

    public static func isSubscriptionActive(identifier: String) -> Bool {
        guard let purchaseInfo = receipt.purchases[identifier] else {
            return false
        }

        return purchaseInfo.expirationDate > referenceDate
    }

    public static func isAnySubscriptionActive() -> Bool {
        return receipt.purchases.values.contains { (purchaseInfo: PurchaseInfo) -> Bool in
            return (purchaseInfo.type == .subscription) && (purchaseInfo.expirationDate > referenceDate)
        }
    }

    private static func fetchCachedReceipt() -> Receipt {
        guard let data = try? keychain.getData(Constants.keychainReceiptKey),
              let receipt = try? JSONDecoder().decode(Receipt.self, from: data) else {
            return .init()
        }

        return receipt
    }

    private static func validateReceipt(success: @escaping (Receipt) -> Void, failure: @escaping (Swift.Error) -> Void = { _ in }) {
        let validator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: validator, forceRefresh: false) { (result: VerifyReceiptResult) in
            switch result {
            case .success(let receipt):
                self.receipt = Receipt(dictionary: receipt) ?? .init()
                success(self.receipt)
            case .error(let error):
                print("[EE] Error validating receipt: \(error)")
                failure(error)
            }
        }
    }
}
