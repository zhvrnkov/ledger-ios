//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import StoreKit

public extension SKProductSubscriptionPeriod {
    var period: SubscriptionPeriod {
        switch unit {
        case .day:
            if numberOfUnits % 7 == 0 {
                return .week(numberOfUnits / 7)
            }
            return .day(numberOfUnits)
        case .week:
            return .week(numberOfUnits)
        case .month:
            return .month(numberOfUnits)
        case .year:
            return .year(numberOfUnits)
        @unknown default:
            return .unknown
        }
    }
}
