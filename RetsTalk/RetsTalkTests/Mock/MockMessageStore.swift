//
//  MockMessageStore.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/20/24.
//

import Foundation

final class MockMessageStore: Persistable, @unchecked Sendable {
    var messages: [Message]
    
    init() {
        let retrospectID = UUID()
        let messages = (0..<100).map {
            Message(retrospectID: retrospectID, role: $0 % 2 == 0 ? .assistant : .user, content: UUID().uuidString)
        }
        self.messages = messages
    }
    
    func add<Entity>(contentsOf entities: [Entity]) throws -> [Entity] {
        entities
    }
    
    func fetch<Entity>(
        by request: any PersistFetchRequestable<Entity>
    ) throws -> [Entity] where Entity: EntityRepresentable {
        let startIndex = request.fetchOffset
        let endIndex = min(request.fetchOffset + request.fetchLimit, messages.count)
        let fetchMessages = Array(messages[startIndex..<endIndex])
        guard let result = fetchMessages as? [Entity] else { return [] }
        
        return result
    }
    
    func update<Entity>(from sourceEntity: Entity, to updatingEntity: Entity) throws -> Entity {
        updatingEntity
    }
    
    func delete<Entity>(contentsOf entities: [Entity]) throws {}
}
