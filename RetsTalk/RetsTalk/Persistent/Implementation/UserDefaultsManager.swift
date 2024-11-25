//
//  UserDefaultsManager.swift
//  RetsTalk
//
//  Created by HanSeung on 11/25/24.
//

import Foundation

final class UserDefaultsManager: Persistable {
    private let userDefaultsContainer: UserDefaults

    init(container: UserDefaults = .standard) {
        self.userDefaultsContainer = container
    }
    
    // MARK: Persistable conformance

    func add<Entity>(contentsOf entities: [Entity]) -> [Entity] where Entity : EntityRepresentable {
        return []
    }
    
    func fetch<Entity>(by request: any PersistFetchRequestable<Entity>) -> [Entity] where Entity : EntityRepresentable {
        return []
    }
    
    func update<Entity>(
        from sourceEntity: Entity,
        to updatingEntity: Entity
    ) -> Entity where Entity : EntityRepresentable {
        return Entity(dictionary: [:])
    }
    
    func delete<Entity>(contentsOf entities: [Entity]) where Entity : EntityRepresentable {
        
    }
    
    func fetch<Entity>() -> Entity? where Entity : EntityRepresentable {
        guard let entityDictionary = userDefaultsContainer.dictionary(forKey: Entity.entityName) else {
            return nil
        }
        
        return Entity(dictionary: entityDictionary)
    }
    
    func update<Entity>(entity: Entity) where Entity: EntityRepresentable {
        let dictionary = entity.mappingDictionary
        
        for dictionaryKey in dictionary.keys {
            userDefaultsContainer.set(dictionary[dictionaryKey], forKey: dictionaryKey)
        }
    }
}
