//
//  RetrospectChatManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Foundation

final class RetrospectChatManager: RetrospectChatManageable {
    private(set) var retrospect: Retrospect
    private(set) var errorOccurred: Swift.Error?
    
    private let messageStorage: Persistable
    private let assistantMessageProvider: AssistantMessageProvidable
    
    private let retrospectChatManagerListener: RetrospectChatManagerListener
    
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
    }
    
    // MARK: RetrospectChatManageable conformance
    
    func sendMessage(_ text: String) async {
        do {
            let userMessage = Message(retrospectID: retrospect.id, role: .user, content: text)
            let addedUserMessage = try messageStorage.add(contentsOf: [userMessage])
            retrospect.append(contentsOf: addedUserMessage)
        } catch {
            errorOccurred = error
        }
        retrospect.status = .inProgress(.waitingForResponse)
        
        await requestAssistentMessage()
    }
    
    func resendLastMessage() async {
        await requestAssistentMessage()
    }
    
    func fetchPreviousMessages() {
        do {
            let request = recentMessageFetchRequest(offset: retrospect.chat.count, amount: Numeric.messageFetchAmount)
            let fetchedMessages = try messageStorage.fetch(by: request)
            retrospect.prepend(contentsOf: fetchedMessages)
        } catch {
            errorOccurred = error
        }
    }
    
    func endRetrospect() {
        do {
            retrospect.status = .finished
            try retrospectChatManagerListener.didUpdateRetrospect(self, retrospect: retrospect)
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    func toggleRetrospectPin() {
        guard retrospectChatManagerListener.shouldTogglePin(self, retrospect: retrospect)
        else {
            errorOccurred = Error.pinUnavailable
            return
        }
        
        do {
            retrospect.isPinned.toggle()
            try retrospectChatManagerListener.didUpdateRetrospect(self, retrospect: retrospect)
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    // MARK: Supporting methods
    
    private func requestAssistentMessage() async {
        do {
            let assistantMessage = try await assistantMessageProvider.requestAssistantMessage(for: retrospect.chat)
            let addedAssistantMessage = try messageStorage.add(contentsOf: [assistantMessage])
            retrospect.append(contentsOf: addedAssistantMessage)
            retrospect.status = .inProgress(.waitingForUserInput)
        } catch {
            retrospect.status = .inProgress(.responseErrorOccurred)
            errorOccurred = error
        }
    }
    
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
