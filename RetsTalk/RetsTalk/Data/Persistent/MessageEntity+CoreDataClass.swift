//
//  Message+CoreDataClass.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/6/24.
//
//

import Foundation
import CoreData

public class MessageEntity: NSManagedObject {
    // Domain -> CoreData Entity
    convenience init(from domain: Message, insertInfo context: NSManagedObjectContext) {
        self.init(context: context)
        isUser = (domain.role == .user)
        content = domain.content
        createdAt = domain.createdAt
    }

    // CoreData Entity -> Domain
    func toDomain() -> Message {
        Message(role: isUser ? .user : .assistant,
                content: content ?? "",
                createdAt: createdAt ?? Date())
    }
}
