//
//  DateComponents+Extension.swift
//  RetsTalk
//
//  Created by KimMinSeok on 12/4/24.
//

import Foundation

extension DateComponents {
    var normalized: DateComponents {
        guard let date = Calendar.current.date(from: self) else { return DateComponents() }
        
        return date.toDateComponents
    }
}
