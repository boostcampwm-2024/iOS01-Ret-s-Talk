//
//  MessageManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Foundation

final class MessageManager: MessageManageable {
    let retrospectID: UUID
    private(set) var messages: [Message] = []
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
    
    func fetchMessages(offset: Int, amount: Int) {
        
    }
    
    func send(_ message: Message) {
        
    }
    
    func endRetrospect() {
        messageManagerListener.didFinishRetrospect(self)
    }
}
