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
        return entities
    }
    
    func fetch<Entity>(
        by request: any PersistFetchRequestable<Entity>
    ) async throws -> [Entity] where Entity: EntityRepresentable {
        let sortedMessages = messages.sorted { lhs, rhs in
            for descriptor in request.sortDescriptors {
                if let key = descriptor.key, key == "createdAt" {
                    let comparisonResult = lhs.createdAt.compare(rhs.createdAt)
                    if descriptor.ascending {
                        return comparisonResult == .orderedAscending
                    } else {
                        return comparisonResult == .orderedDescending
                    }
                }
            }
            return false
        }
        
        let firstIndex = request.fetchOffset
        let lastIndex = min(request.fetchOffset + request.fetchLimit, sortedMessages.count)
        let fetchMessages = Array(sortedMessages[firstIndex..<lastIndex])
        
        guard let result = fetchMessages as? [Entity] else {
            return []
        }
        
        return result
    }
    
    func update<Entity>(from sourceEntity: Entity, to updatingEntity: Entity) async throws -> Entity {
        return updatingEntity
    }
    
    func delete<Entity>(contentsOf entities: [Entity]) async throws {
        
    }
}
