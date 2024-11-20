//
//  MessageManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Foundation
import Combine

final class MessageManager: MessageManageable {
    var retrospectSubject: CurrentValueSubject<Retrospect, Never>
    private(set) var messageManagerListener: MessageManagerListener
    let persistent: Persistable

    init(
        retrospect: Retrospect,
        messageManagerListener: MessageManagerListener,
        persistent: Persistable
    ) {
        self.retrospectSubject = CurrentValueSubject(retrospect)
        self.messageManagerListener = messageManagerListener
        self.persistent = persistent
    }
    
    func fetchMessages(offset: Int, amount: Int) async throws {
        let predicate = NSPredicate(format: "retrospectID = %@", argumentArray: [retrospectSubject.value.id])
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        let request = PersistfetchRequest<Message>(
            predicate: predicate,
            sortDescriptors: [sortDescriptor],
            fetchLimit: amount,
            fetchOffset: offset
        )
        
        let fetchedEntities = try await persistent.fetch(by: request)
        
        retrospectSubject.value.chat.append(contentsOf: fetchedEntities)
    }
    
    func send(_ message: Message) async throws {
        
    }
    
    func endRetrospect() {
        messageManagerListener.didFinishRetrospect(self)
    }
}
