//
//  PersistFetchRequest.swift
//  RetsTalk
//
//  Created by Byeongjo Koo on 11/25/24.
//

import Foundation

struct PersistFetchRequest<Entity: EntityRepresentable>: PersistFetchRequestable {
    var predicate: CustomPredicate?
    var sortDescriptors: [CustomSortDescriptor]
    var fetchLimit: Int
    var fetchOffset: Int
    
    init(
        predicate: CustomPredicate? = nil,
        sortDescriptors: [CustomSortDescriptor] = [],
        fetchLimit: Int,
        fetchOffset: Int = 0
    ) {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.fetchLimit = fetchLimit
        self.fetchOffset = fetchOffset
    }
}
