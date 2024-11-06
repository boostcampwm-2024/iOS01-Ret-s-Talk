//
//  Message+CoreDataClass.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/5/24.
//
//

import Foundation
import CoreData

public class Message: NSManagedObject {
    
    @discardableResult
    static func addAndSave(with object: MessageDTO) -> Result<Message, Error> {
        do {
            let context = CoreDataStorage.shared.context
            let message = Message(context: context)
            message.content = object.content
            message.isUser = object.isUser
            
            try CoreDataStorage.shared.saveContext()
            return .success(message)
        } catch {
            return .failure(error)
        }
    }
}
