//
//  Date+Extensions.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
extension TimeInterval {
    func asMinutes() -> Double { return self / (60.0) }
    func asHours()   -> Double { return self / (60.0 * 60.0) }
    func asDays()    -> Double { return self / (60.0 * 60.0 * 24.0) }
    func asWeeks()   -> Double { return self / (60.0 * 60.0 * 24.0 * 7.0) }
    func asMonths()  -> Double { return self / (60.0 * 60.0 * 24.0 * 30.4369) }
    func asYears()   -> Double { return self / (60.0 * 60.0 * 24.0 * 365.2422) }
}
