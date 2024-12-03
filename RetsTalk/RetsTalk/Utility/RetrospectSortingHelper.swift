//
//  RetrospectSortingHelper.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

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
}
