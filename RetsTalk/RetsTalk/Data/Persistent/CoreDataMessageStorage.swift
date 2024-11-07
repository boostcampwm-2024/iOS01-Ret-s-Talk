//
//  CoreDataMessageStorage.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/7/24.
//

import CoreData

final class CoreDataMessageStorage {
    private let coreDataStorage: CoreDataStorage

    init(coreDataStorage: CoreDataStorage = CoreDataStorage.shared) {
        self.coreDataStorage = coreDataStorage
    }

    @discardableResult
    func save(_ message: Message) throws -> Message {
        let entity = MessageEntity(from: message, insertInfo: coreDataStorage.context)
        try coreDataStorage.saveContext()

        return entity.toDomain()
    }
    
    func fetchAll() throws -> [Message] {
        let fetchRequest = try coreDataStorage.context.fetch(MessageEntity.fetchRequest())
        let messages = fetchRequest.map { $0.toDomain() }
        
        return messages
    }
    
    func removeAll() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MessageEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try coreDataStorage.context.execute(deleteRequest)
        try coreDataStorage.saveContext()
    }
}
