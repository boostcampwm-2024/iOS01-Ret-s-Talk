//
//  PersistFetchRequestable.swift
//  RetsTalk
//
//  Created on 11/17/24.
//

import Foundation

protocol PersistFetchRequestable<Entity> {
    associatedtype Entity: EntityRepresentable
    
    var predicate: NSPredicate? { get }
    var sortDescriptors: [NSSortDescriptor] { get }
    /// 검색을 통해 최대로 가져올 수 있는 수.
    var fetchLimit: Int { get }
    /// 검색 후 데이터를 가져오는 시작점.
    var fetchOffset: Int { get }
}

struct PersistfetchRequest<Entity: EntityRepresentable>: PersistFetchRequestable {
    var predicate: NSPredicate?
    var sortDescriptors: [NSSortDescriptor]
    var fetchLimit: Int
    var fetchOffset: Int
    
    init(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        fetchLimit: Int,
        fetchOffset: Int = 0
    ) {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.fetchLimit = fetchLimit
        self.fetchOffset = fetchOffset
    }
}
