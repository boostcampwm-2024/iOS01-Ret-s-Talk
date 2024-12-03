//
//  RetrospectSortingHelper.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

import Foundation

enum RetrospectSortingHelper {
    static func execute(_ retrospects: [Retrospect]) -> SortedRetrospects {
        let pinnedRetrospects = retrospects
            .filter { $0.isPinned }
            .sorted(by: { $0.createdAt > $1.createdAt })
        let inProgressRetrospects = retrospects
            .filter { ($0.status != .finished) }
            .sorted(by: { $0.createdAt > $1.createdAt })
        let finishedRetrospects = retrospects
            .filter { ($0.status == .finished) && !$0.isPinned }
            .sorted(by: { $0.createdAt > $1.createdAt })
        
        return SortedRetrospects([pinnedRetrospects, inProgressRetrospects, finishedRetrospects])
    }
    
    static func totalCount(_ retrospects: [Retrospect]) -> Int { retrospects.count }
    
    static func datesCount(_ retrospects: [Retrospect]) -> Int {
        let uniqueDates = Set(retrospects.map { retrospect in
            let formatter = DateFormatter()
            formatter.dateFormat = Texts.dateFormat
            return formatter.string(from: retrospect.createdAt)
        })
        return uniqueDates.count
    }
}

private extension RetrospectSortingHelper {
    enum Texts {
        static let dateFormat = "yyyy-MM-dd"
    }
}
