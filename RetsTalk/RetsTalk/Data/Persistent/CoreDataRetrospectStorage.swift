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

    @discardableResult
    func save(_ retrospect: Retrospect) throws -> Retrospect {
        let entity = RetrospectEntity(from: retrospect, insertInfo: coreDataStorage.context)
        try coreDataStorage.saveContext()

        return try entity.toDomain()
    }
    
    func fetchAll() throws -> [Retrospect] {
        let fetchRequest = try coreDataStorage.context.fetch(RetrospectEntity.fetchRequest())
        let retrospects = try fetchRequest.map { try $0.toDomain() }
        
        return retrospects
    }
    
    func removeAll() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RetrospectEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try coreDataStorage.context.execute(deleteRequest)
        try coreDataStorage.saveContext()
    }
}
