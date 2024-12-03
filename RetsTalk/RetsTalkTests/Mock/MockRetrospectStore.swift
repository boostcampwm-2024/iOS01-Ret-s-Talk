//
//  MockRetrospectStore.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/24/24.
//

import XCTest

final class MockRetrospectStore: Persistable {
    nonisolated(unsafe) static var fetchHadler: ((any PersistFetchRequestable) -> [Retrospect])?
    
    func add<Entity>(contentsOf entities: [Entity]) throws -> [Entity] {
        entities
    }
    
    func fetch<Entity>(by request: any PersistFetchRequestable<Entity>) throws -> [Entity] {
        guard let fetchHadler = MockRetrospectStore.fetchHadler
        else {
            XCTFail("fetchHadler가 설정되지 않았습니다.")
            return []
        }
        
        return (fetchHadler(request) as? [Entity]) ?? []
    }
    
    func update<Entity>(from sourceEntity: Entity, to updatingEntity: Entity) throws -> Entity {
        updatingEntity
    }
    
    func delete<Entity>(contentsOf entities: [Entity]) throws {}
}
