//
//  MessageManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Combine
import Foundation

final class MessageManager: MessageManageable {
    private var retrospect: Retrospect {
        didSet { retrospectSubject.send(retrospect) }
    }
    private(set) var retrospectSubject: CurrentValueSubject<Retrospect, Never>
    
    private let messageStorage: Persistable
    private let assistantMessageProvider: AssistantMessageProvidable
    
    private(set) var messageManagerListener: MessageManagerListener
    
    // MARK: Initialization

    init(
        retrospect: Retrospect,
        persistent: Persistable,
        assistantMessageProvider: AssistantMessageProvidable,
        messageManagerListener: MessageManagerListener
    ) {
        self.retrospect = retrospect
        self.retrospectSubject = CurrentValueSubject(retrospect)
        self.messageStorage = persistent
        self.assistantMessageProvider = assistantMessageProvider
        self.messageManagerListener = messageManagerListener
    }
    
    // MARK: MessageManageable conformance
    
    func fetchMessages(offset: Int, amount: Int) async throws {
        let request = recentMessageFetchRequest(offset: offset, amount: amount)
        let fetchedMessages = try await messageStorage.fetch(by: request)
        retrospect.append(contentsOf: fetchedMessages)
    }
    
    func send(_ message: Message) async throws {
        
    }
    
    func endRetrospect() {
        messageManagerListener.didFinishRetrospect(self)
    }
    
    // MARK: Supporting methods
    
    private func recentMessageFetchRequest(offset: Int, amount: Int) -> PersistfetchRequest<Message> {
        let matchingRetorspect = NSPredicate(format: "retrospectID = %@", argumentArray: [retrospect.id])
        let recentDateSorting = NSSortDescriptor(key: "createdAt", ascending: false)
        let request = PersistfetchRequest<Message>(
            predicate: matchingRetorspect,
            sortDescriptors: [recentDateSorting],
            fetchLimit: amount,
            fetchOffset: offset
        )
        return request
    }
}
