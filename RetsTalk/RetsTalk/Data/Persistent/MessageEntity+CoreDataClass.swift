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
    @discardableResult
    static func addAndSave(with object: MessageDTO) -> Result<MessageEntity, Error> {
        do {
            let context = CoreDataStorage.shared.context
            let message = MessageEntity(context: context)
            message.content = object.content
            message.isUser = object.isUser

            try CoreDataStorage.shared.saveContext()
            return .success(message)
        } catch {
            return .failure(error)
        }
    }
}
