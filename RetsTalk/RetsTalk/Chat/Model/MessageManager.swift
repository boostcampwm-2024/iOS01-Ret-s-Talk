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
    
    init(retrospect: Retrospect, messageManagerListener: MessageManagerListener) {
        self.retrospectSubject = CurrentValueSubject(retrospect)
        self.messageManagerListener = messageManagerListener
    }
    
    func fetchMessages(offset: Int, amount: Int) async throws {
        
    }
    
    func send(_ message: Message) async throws {
        
    }
    
    func endRetrospect() {
        messageManagerListener.didFinishRetrospect(self)
    }
}
