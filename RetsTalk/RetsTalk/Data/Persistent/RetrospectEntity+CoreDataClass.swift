//
//  Retrospect+CoreDataClass.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/5/24.
//
//

import Foundation
import CoreData

public class RetrospectEntity: NSManagedObject {
    // Domain -> CoreData Entity
    convenience init(from domain: Retrospect, insertInfo context: NSManagedObjectContext) {
        self.init(context: context)
        summary = domain.summary
        isBookmarked = domain.isBookmarked
        isFinished = domain.isFinished
        createdAt = domain.createdAt
        domain.chat.forEach { message in
            addToChat(MessageEntity(from: message, insertInfo: context))
        }
    }

    // CoreData Entity -> Domain
    func toDomain() throws -> Retrospect {
        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "retrospect == %@", self)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        let fetchedChat: [MessageEntity] = try CoreDataStorage.shared.context.fetch(fetchRequest)
        
        let resultChat = fetchedChat.map { $0.toDomain() }
        
        return Retrospect(
            summary: summary,
            isFinished: isFinished,
            isBookmarked: isBookmarked,
            createdAt: createdAt ?? Date(),
            chat: resultChat
        )
    }
}
