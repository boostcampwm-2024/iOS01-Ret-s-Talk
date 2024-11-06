//
//  MessageDTO.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/5/24.
//

import CoreData

struct MessageDTO: CoreDataConvertible {
    typealias Entity = MessageEntity

    let isUser: Bool
    let content: String

    func toEntity(context: NSManagedObjectContext) -> MessageEntity {
        let message = MessageEntity(context: context)
        message.isUser = isUser
        message.content = content

        return message
    }
}
