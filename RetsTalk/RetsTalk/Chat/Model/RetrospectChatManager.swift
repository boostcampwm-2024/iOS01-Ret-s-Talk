//
//  RetrospectChatManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Combine
import Foundation

final class RetrospectChatManager: RetrospectChatManageable {
    private let messageStorage: Persistable
    private let assistantMessageProvider: AssistantMessageProvidable
    private let retrospectChatManagerListener: RetrospectChatManagerListener
    
    private let retrospectSubject: CurrentValueSubject<Retrospect, Never>
    
    private(set) var retrospect: Retrospect {
        didSet {
            syncRetrospect()
            retrospectSubject.send(retrospect)
        }
    }
    private(set) var errorSubject: PassthroughSubject<Swift.Error, Never>
    
    // MARK: Initialization

    init(
        retrospect: Retrospect,
        messageStorage: Persistable,
        assistantMessageProvider: AssistantMessageProvidable,
        retrospectChatManagerListener: RetrospectChatManagerListener
    ) {
        self.retrospect = retrospect
        self.messageStorage = messageStorage
        self.assistantMessageProvider = assistantMessageProvider
        self.retrospectChatManagerListener = retrospectChatManagerListener
        
        retrospectSubject = CurrentValueSubject(retrospect)
        errorSubject = PassthroughSubject()
        
        if retrospect.chat.isEmpty {
            fetchPreviousMessages()
        }
    }
    
    // MARK: RetrospectChatManageable conformance
    
    var retrospectPublisher: AnyPublisher<Retrospect, Never> {
        retrospectSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<Swift.Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    func sendMessage(_ content: String) async {
        do {
            let userMessage = Message(retrospectID: retrospect.id, role: .user, content: content)
            let addedUserMessage = try messageStorage.add(contentsOf: [userMessage])
            retrospect.append(contentsOf: addedUserMessage)
        } catch {
            errorSubject.send(error)
        }
        retrospect.status = .inProgress(.waitingForResponse)
        
        await requestAssistantMessage()
    }
    
    func requestAssistantMessage() async {
        do {
            let assistantMessage = try await assistantMessageProvider.requestAssistantMessage(for: retrospect)
            let addedAssistantMessage = try messageStorage.add(contentsOf: [assistantMessage])
            retrospect.append(contentsOf: addedAssistantMessage)
            retrospect.status = .inProgress(.waitingForUserInput)
        } catch {
            retrospect.status = .inProgress(.responseErrorOccurred)
            errorSubject.send(error)
        }
    }
    
    func fetchPreviousMessages() {
        do {
            let request = recentMessageFetchRequest(offset: retrospect.chat.count, amount: Numeric.messageFetchAmount)
            let fetchedMessages = try messageStorage.fetch(by: request)
            retrospect.prepend(contentsOf: fetchedMessages.reversed())
        } catch {
            errorSubject.send(error)
        }
    }
    
    func endRetrospect() {
        retrospect.status = .finished
    }
    
    func toggleRetrospectPin() {
        guard retrospectChatManagerListener.shouldTogglePin(self, retrospect: retrospect)
        else {
            errorSubject.send(Error.pinUnavailable)
            return
        }
        
        retrospect.isPinned.toggle()
    }
    
    // MARK: Retrospect sync
    
    private func syncRetrospect() {
        do {
            try retrospectChatManagerListener.didUpdateRetrospect(self, retrospect: retrospect)
        } catch {
            errorSubject.send(error)
        }
    }
    
    // MARK: FetchRequest setup
    
    private func recentMessageFetchRequest(offset: Int, amount: Int) -> PersistFetchRequest<Message> {
        let matchingRetorspect = CustomPredicate(format: Texts.matchingRetorspect, argumentArray: [retrospect.id])
        let recentDateSorting = CustomSortDescriptor(key: Texts.messageSortKey, ascending: false)
        let request = PersistFetchRequest<Message>(
            predicate: matchingRetorspect,
            sortDescriptors: [recentDateSorting],
            fetchLimit: amount,
            fetchOffset: offset
        )
        return request
    }
}

// MARK: - Error

fileprivate extension RetrospectChatManager {
    enum Error: LocalizedError {
        case pinUnavailable
        
        var errorDescription: String? {
            switch self {
            case .pinUnavailable:
                "회고를 고정할 수 없습니다. 최대 고정 개수는 2개입니다."
            }
        }
    }
}

// MARK: - Constants

fileprivate extension RetrospectChatManager {
    enum Numeric {
        static let messageFetchAmount = 30
    }
    
    enum Texts {
        static let matchingRetorspect = "retrospectID = %@"
        static let messageSortKey = "createdAt"
    }
}
