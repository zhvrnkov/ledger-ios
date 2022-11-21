//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import StoreKit

public final class Product: CustomStringConvertible {
    public let identifier: String
    public let title: String
    public let info: String
    public let price: String?
    
    public let period: SubscriptionPeriod?
    public let introductoryOffer: IntroductoryOffer?

    public let rawPrice: NSDecimalNumber
    public let locale: Locale

    public var description: String {
        return "\(identifier) [\(price ?? "N/A")] with period \(period?.description() ?? "N/A")"
    }

    let storeProduct: SKProduct

    init(storeProduct: SKProduct) {
        self.storeProduct = storeProduct
        identifier = storeProduct.productIdentifier
        title = storeProduct.localizedTitle
        info = storeProduct.localizedDescription
        price = storeProduct.localizedPrice

        introductoryOffer = .init(storeProduct)

        rawPrice = storeProduct.price
        locale = storeProduct.priceLocale

        period = storeProduct.subscriptionPeriod?.period
    }
}

extension Product: Equatable {
    public static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
