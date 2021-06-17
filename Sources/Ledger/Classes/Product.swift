//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import StoreKit

public final class Product {
    public let identifier: String
    public let title: String
    public let description: String
    public let price: String?

    public let rawPrice: NSDecimalNumber
    public let locale: Locale

    let storeProduct: SKProduct

    init(storeProduct: SKProduct) {
        self.storeProduct = storeProduct
        identifier = storeProduct.productIdentifier
        title = storeProduct.localizedTitle
        description = storeProduct.localizedDescription
        price = storeProduct.localizedPrice

        rawPrice = storeProduct.price
        locale = storeProduct.priceLocale
    }
}
