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
    
    init(retrospectID: UUID, messageManagerListener: MessageManagerListener) {
        self.retrospectID = retrospectID
        self.messageManagerListener = messageManagerListener
    }
    
    func fetchMessages(offset: Int, amount: Int) {
        
    }
    
    func send(_ message: Message) {
        
    }
    
    func endRetrospect() {
        
    }
}
