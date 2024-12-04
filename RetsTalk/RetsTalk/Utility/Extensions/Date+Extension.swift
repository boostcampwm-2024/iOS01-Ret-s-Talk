//
//  Date+Extension.swift
//  RetsTalk
//
//  Created by HanSeung on 11/21/24.
//

import Foundation

extension Date {
    var formattedToKoreanStyle: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Constants.dateLocaleIdentifier)
        
        switch self {
        case _ where calendar.isDateInToday(self):
            dateFormatter.dateFormat = Constants.dateFormatRecent
            return dateFormatter.string(from: self)
        case _ where calendar.isDateInYesterday(self):
            return Constants.dateFormatYesterday
        default:
            dateFormatter.dateFormat = Constants.dateFormat
            return dateFormatter.string(from: self)
        }
    }
    
    var toDateComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
    
    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static func startOfMonth(year: Int, month: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        return Calendar.current.date(from: components)
    }
}
