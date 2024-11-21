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
}
