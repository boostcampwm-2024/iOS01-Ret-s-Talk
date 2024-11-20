//
//  MessageManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Foundation
import Combine

final class MessageManager: MessageManageable {
    private var retrospect: Retrospect {
        didSet { retrospectSubject.send(retrospect) }
    }
    private(set) var retrospectSubject: CurrentValueSubject<Retrospect, Never>
    private(set) var messageManagerListener: MessageManagerListener
    let persistent: Persistable

    init(
        retrospect: Retrospect,
        messageManagerListener: MessageManagerListener,
        persistent: Persistable
    ) {
        self.retrospect = retrospect
        self.retrospectSubject = CurrentValueSubject(retrospect)
        self.messageManagerListener = messageManagerListener
        self.persistent = persistent
    }
    
    func fetchMessages(offset: Int, amount: Int) async throws {
        let predicate = NSPredicate(format: "retrospectID = %@", argumentArray: [retrospect.id])
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        let request = PersistfetchRequest<Message>(
            predicate: predicate,
            sortDescriptors: [sortDescriptor],
            fetchLimit: amount,
            fetchOffset: offset
        )
        
        let fetchedEntities = try await persistent.fetch(by: request)
        
        retrospect.chat.append(contentsOf: fetchedEntities)
    }
    
    func send(_ message: Message) async throws {
        
    }
    
    func endRetrospect() {
        messageManagerListener.didFinishRetrospect(self)
    }
}
