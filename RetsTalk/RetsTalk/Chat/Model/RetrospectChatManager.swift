//
//  MessageManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Combine
import Foundation

final class RetrospectChatManager: RetrospectChatManageable, @unchecked Sendable {
    private var retrospect: Retrospect {
        didSet { retrospectSubject.send(retrospect) }
    }
    private(set) var retrospectSubject: CurrentValueSubject<Retrospect, Never>
    
    private let messageStorage: Persistable
    private let assistantMessageProvider: AssistantMessageProvidable
    
    private(set) var retrospectChatManagerListener: RetrospectChatManagerListener
    
    // MARK: Initialization

    init(
        retrospect: Retrospect,
        persistent: Persistable,
        assistantMessageProvider: AssistantMessageProvidable,
        retrospectChatManagerListener: RetrospectChatManagerListener
    ) {
        self.retrospect = retrospect
        self.retrospectSubject = CurrentValueSubject(retrospect)
        self.messageStorage = persistent
        self.assistantMessageProvider = assistantMessageProvider
        self.retrospectChatManagerListener = retrospectChatManagerListener
    }
    
    // MARK: MessageManageable conformance
    
    func fetchMessages(offset: Int, amount: Int) async throws {
        let request = recentMessageFetchRequest(offset: offset, amount: amount)
        let fetchedMessages = try await messageStorage.fetch(by: request)
        retrospect.prepend(contentsOf: fetchedMessages)
    }
    
    func send(_ message: Message) async throws {
        let addedUserMessage = try await messageStorage.add(contentsOf: [message])
        retrospect.append(contentsOf: addedUserMessage)
        retrospect.status = .inProgress(.waitingForResponse)
        do {
            let assistantMessage = try await assistantMessageProvider.requestAssistantMessage(for: retrospect.chat)
            let addedAssistantMessage = try await messageStorage.add(contentsOf: [assistantMessage])
            retrospect.append(contentsOf: addedAssistantMessage)
            retrospect.status = .inProgress(.waitingForUserInput)
        } catch {
            retrospect.status = .inProgress(.responseErrorOccurred)
            throw error
        }
    }
    
    func endRetrospect() {
        retrospectChatManagerListener.didFinishRetrospect(self)
    }
    
    // MARK: Supporting methods
    
    private func recentMessageFetchRequest(offset: Int, amount: Int) -> PersistFetchRequest<Message> {
        let matchingRetorspect = CustomPredicate(format: "retrospectID = %@", argumentArray: [retrospect.id])
        let recentDateSorting = CustomSortDescriptor(key: "createdAt", ascending: false)
        let request = PersistFetchRequest<Message>(
            predicate: matchingRetorspect,
            sortDescriptors: [recentDateSorting],
            fetchLimit: amount,
            fetchOffset: offset
        )
        return request
    }
}
