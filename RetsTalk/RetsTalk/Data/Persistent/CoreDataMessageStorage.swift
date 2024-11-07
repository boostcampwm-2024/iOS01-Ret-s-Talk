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

    func save(_ message: Message) throws -> Message {
        let entity = MessageEntity(from: message, insertInfo: coreDataStorage.context)
        try coreDataStorage.saveContext()

        return entity.toDomain()
    }
}
