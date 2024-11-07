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
        let fetchRequest: NSFetchRequest<RetrospectEntity> = RetrospectEntity.fetchRequest()
        let retrospectEntities = try coreDataStorage.context.fetch(fetchRequest)
        
        // FIXME: 회고와 관련된 채팅 삭제 기능 고치기
        for retrospect in retrospectEntities {
            if let chats = retrospect.chat as? Set<MessageEntity> {
                for chat in chats {
                    coreDataStorage.context.delete(chat)
                }
            }
            coreDataStorage.context.delete(retrospect)
        }
        
        try coreDataStorage.saveContext()
    }
}
