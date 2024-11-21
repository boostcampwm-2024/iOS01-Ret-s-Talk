//
//  MockMessageStore.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/20/24.
//

import Foundation

final class MockMessageStore: Persistable {
    var messages: [Message]
    
    init(messages: [Message]) {
        self.messages = messages
    }
    
    func add<Entity>(contentsOf entities: [Entity]) async throws -> [Entity] {
        entities
    }
    
    func fetch<Entity>(
        by request: any PersistFetchRequestable<Entity>
    ) async throws -> [Entity] where Entity: EntityRepresentable {

        messages.sort { $0.createdAt < $1.createdAt }
        let firstIndex = request.fetchOffset
        let lastIndex = min(request.fetchOffset + request.fetchLimit, messages.count)
        let fetchMessages = Array(messages[firstIndex..<lastIndex])
        
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
