//
//  MessageManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Foundation

final class MessageManager: MessageManageable {
    let retrospectID: UUID
    @Published private(set) var messages: [Message] = []
    private(set) var messageManagerListener: MessageManagerListener
    let persistent: Persistable
    
    init(
        retrospectID: UUID,
        messageManagerListener: MessageManagerListener,
        persistent: Persistable
    ) {
        self.retrospectID = retrospectID
        self.messageManagerListener = messageManagerListener
        self.persistent = persistent
    }
    
    func fetchMessages(offset: Int, amount: Int) async throws {
        let predicate = NSPredicate(format: "retrospectID = %@", argumentArray: [retrospectID])
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        let request = PersistfetchRequest<Message>(
            predicate: predicate,
            sortDescriptors: [sortDescriptor],
            fetchLimit: amount,
            fetchOffset: offset
        )
        
        let fetchedEntities = try await persistent.fetch(by: request)
        
        messages.append(contentsOf: fetchedEntities)
    }
    
    func send(_ message: Message) {
        
    }
    
    func endRetrospect() {
        messageManagerListener.didFinishRetrospect(self)
    }
}
