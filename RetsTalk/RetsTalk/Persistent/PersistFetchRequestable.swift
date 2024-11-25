//
//  PersistFetchRequestable.swift
//  RetsTalk
//
//  Created on 11/17/24.
//

import Foundation

protocol PersistFetchRequestable<Entity>: Sendable {
    associatedtype Entity: EntityRepresentable
    
    var predicate: CustomPredicate? { get }
    var sortDescriptors: [CustomSortDescriptor] { get }
    /// 검색을 통해 최대로 가져올 수 있는 수.
    var fetchLimit: Int { get }
    /// 검색 후 데이터를 가져오는 시작점.
    var fetchOffset: Int { get }
}

struct CustomPredicate: @unchecked Sendable {
    let format: String
    let argumentArray: [Any]
    
    var nsPredicate: NSPredicate {
        NSPredicate(format: format, argumentArray: argumentArray)
    }
}

struct CustomSortDescriptor {
    let key: String
    let ascending: Bool
    
    var nsSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(key: key, ascending: ascending)
    }
}
