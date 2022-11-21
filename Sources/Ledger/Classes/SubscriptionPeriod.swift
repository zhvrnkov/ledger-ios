//
//  Copyright © 2022 Rosberry. All rights reserved.
//

import Foundation

public enum SubscriptionPeriod {
    case day(_ count: Int)
    case week(_ count: Int)
    case month(_ count: Int)
    case year(_ count: Int)
    case unknown

    public var dayCount: Int {
        switch self {
        case .day(let count):
            return count
        case .week(let count):
            return count * 7
        case .month(let count):
            return count * 30
        case .year(let count):
            return count * 365
        case .unknown:
            return -1
        }
    }

    public func description() -> String {
        switch self {
        case let .day(count):
           return descriptionPeriod("day", count: count)
        case let .week(count):
           return descriptionPeriod("week", count: count)
        case let .month(count):
           return descriptionPeriod("month", count: count)
        case let .year(count):
           return descriptionPeriod("year", count: count)
        case .unknown:
            return "N/A"
        }
    }

    public func descriptionWithFormat(_ dateFormat: String = "d MMMM, yyyy") -> String {
        var dateComponents: DateComponents = .init()
        switch self {
        case let .day(count):
            dateComponents.day = count
        case let .week(count):
            dateComponents.weekOfMonth = count
        case let .month(count):
            dateComponents.month = count
        case let .year(count):
            dateComponents.year = count
        case .unknown:
            return "N/A"
        }
        return descriptionEnded(dateComponents, dateFormat: dateFormat)
    }

    public var numberOfUnits: Int? {
        switch self {
        case .day(let count), .week(let count), .month(let count), .year(let count):
            return count
        case .unknown:
            return nil
        }
    }

    private func descriptionPeriod(_ period: String, count: Int) -> String {
        count <= 1 ? "\(count) " + period : "\(count) " + period + "s"
    }

    private func descriptionEnded(_ dateComponents: DateComponents, dateFormat: String) -> String {
        let date = Calendar.current.date(byAdding: dateComponents, to: Date()) ?? .init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
}

extension SubscriptionPeriod: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.dayCount < rhs.dayCount
    }
}
