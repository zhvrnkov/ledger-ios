//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import SwiftyStoreKit

public struct PurchaseInfo: Codable {
    public enum PurchaseType: String, Codable {
        case nonConsumable
        case subscription
    }

    public let identifier: String
    public let type: PurchaseType
    public let expirationDate: Date
    public let quantity: Int

    init?(dictionary: [String: Any]) {
        guard let identifier = dictionary["product_id"] as? String else {
            return nil
        }

        self.identifier = identifier
        quantity = (dictionary["quantity"] as? Int) ?? 1
        if let expirationTimestampString = dictionary["expires_date_ms"] as? String,
           let expirationTimestamp = TimeInterval(expirationTimestampString) {
            type = .subscription
            expirationDate = Date(timeIntervalSince1970: expirationTimestamp / 1000.0)
        }
        else {
            type = .nonConsumable
            expirationDate = Date.distantFuture
        }
    }
}

public struct Receipt: Codable {
    public let creationDate: Date
    public var purchases: [String: PurchaseInfo]

    init() {
        creationDate = Date()
        purchases = [:]
    }

    init?(dictionary: [String: Any]) {
        guard let receiptDict = dictionary["receipt"] as? [String: Any],
              let purchasesDict = receiptDict["in_app"] as? [[String: Any]] else {
            return nil
        }

        var purchases: [String: PurchaseInfo] = [:]
        for purchaseDict in purchasesDict {
            guard let info = PurchaseInfo(dictionary: purchaseDict) else {
                continue
            }

            if let existingPurchase = purchases[info.identifier] {
                purchases[info.identifier] = info.expirationDate > existingPurchase.expirationDate ? info : existingPurchase
            }
            else {
                purchases[info.identifier] = info
            }
        }
        self.purchases = purchases

        if let creationTimestampString = receiptDict["receipt_creation_date_ms"] as? String,
           let creationTimestamp = TimeInterval(creationTimestampString) {
            creationDate = Date(timeIntervalSince1970: creationTimestamp / 1000.0)
        }
        else {
            creationDate = Date()
        }
    }
}
