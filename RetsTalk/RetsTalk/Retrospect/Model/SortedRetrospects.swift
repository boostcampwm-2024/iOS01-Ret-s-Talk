//
//  SortedRetrospects.swift
//  RetsTalk
//
//  Created by HanSeung on 12/2/24.
//

import Foundation

struct SortedRetrospects {
    private let retrospects: [[Retrospect]]
    
    init(_ retrospects: [[Retrospect]] = [[], [], []]) {
        self.retrospects = retrospects
    }
    
    subscript(row: Int) -> [Retrospect] { retrospects[row] }
    subscript(row: Int, column: Int) -> Retrospect { retrospects[row][column] }
    
    var totalCount: Int { retrospects.flatMap { $0 }.count }
    var datesCount: Int {
        let allRetrospects = retrospects.flatMap { $0 }
        let uniqueDates = Set(allRetrospects.map { retrospect in
            let formatter = DateFormatter()
            formatter.dateFormat = Texts.dateFormat
            return formatter.string(from: retrospect.createdAt)
        })
        
        return uniqueDates.count
    }
}

// MARK: - Constants

private extension SortedRetrospects {
    enum Texts {
        static let dateFormat = "yyyy-MM-dd"
    }
}
