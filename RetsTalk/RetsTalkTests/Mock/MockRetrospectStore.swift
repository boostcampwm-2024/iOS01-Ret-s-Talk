//
//  MockRetrospectStore.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/24/24.
//

import Foundation

final class MockRetrospectStore: Persistable {
    var retrospects: [Retrospect] = []
    
    init(retrospects: [Retrospect]) {
        self.retrospects = retrospects
    }
    
    func add<Entity>(contentsOf entities: [Entity]) async throws -> [Entity] {
        return entities
    }
    
    func fetch<Entity>(by request: any PersistFetchRequestable<Entity>) async throws -> [Entity] {
        retrospects.sort { $0.createdAt < $1.createdAt }
        let firstIndex = request.fetchOffset
        let lastIndex = min(request.fetchOffset + request.fetchLimit, retrospects.count)
        let fetchMessages = Array(retrospects[firstIndex..<lastIndex])
        
        guard let result = fetchMessages as? [Entity] else {
            return []
        }
        
        return result
    }
    
    func update<Entity>(from sourceEntity: Entity, to updatingEntity: Entity) async throws -> Entity {
        updatingEntity
    }
    
    func delete<Entity>(contentsOf entities: [Entity]) async throws {}
}
