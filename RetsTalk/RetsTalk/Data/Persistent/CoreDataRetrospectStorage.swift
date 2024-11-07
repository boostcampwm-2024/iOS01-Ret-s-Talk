//
//  CoreDataRetrospectEntity.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/7/24.
//

import CoreData

final class CoreDataRetrospectStorage {
    private let coreDataStorage: CoreDataStorage

    init(coreDataStorage: CoreDataStorage = CoreDataStorage.shared) {
        self.coreDataStorage = coreDataStorage
    }

    func save(_ retrospect: Retrospect) throws -> Retrospect {
        let entity = RetrospectEntity()
        try coreDataStorage.saveContext()

        return try entity.toDomain()
    }
}
