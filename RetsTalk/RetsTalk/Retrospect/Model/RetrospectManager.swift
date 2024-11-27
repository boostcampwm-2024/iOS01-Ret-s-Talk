//
//  RetrospectManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Foundation

typealias RetrospectAssistantProvidable = AssistantMessageProvidable & SummaryProvider

final class RetrospectManager: RetrospectManageable {
    private let userID: UUID
    private let retrospectStorage: Persistable
    private let retrospectAssistantProvider: RetrospectAssistantProvidable
    
    private var previousRetrospects: Set<Retrospect>
    
    private(set) var retrospects: [Retrospect]
    private(set) var newRetrospectsManager: RetrospectChatManageable?
    private(set) var errorOccurred: Swift.Error?
    
    // MARK: Initialization
    
    nonisolated init(
        userID: UUID,
        retrospectStorage: Persistable,
        retrospectAssistantProvider: RetrospectAssistantProvidable
    ) {
        self.userID = userID
        self.retrospectStorage = retrospectStorage
        self.retrospectAssistantProvider = retrospectAssistantProvider
        
        previousRetrospects = []
        retrospects = []
    }
    
    // MARK: RetrospectManageable conformance
    
    func createRetrospect() async {
        do {
            newRetrospectsManager = nil
            let newRetrospect = try await createNewRetrospect()
            retrospects.append(newRetrospect)
            let retrospectChatManager = RetrospectChatManager(
                retrospect: newRetrospect,
                messageStorage: retrospectStorage,
                assistantMessageProvider: retrospectAssistantProvider,
                retrospectChatManagerListener: self
            )
            newRetrospectsManager = retrospectChatManager
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    func fetchRetrospects(of kindSet: Set<Retrospect.Kind>) async {
        do {
            for kind in kindSet {
                let request = retrospectFetchRequest(for: kind)
                let fetchedRetrospects = try await retrospectStorage.fetch(by: request)
                for retrospect in fetchedRetrospects where !retrospects.contains(retrospect) {
                    retrospects.append(retrospect)
                }
            }
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    func togglePinRetrospect(_ retrospect: Retrospect) async {
        do {
            guard isPinAvailable else { throw Error.reachInProgressLimit }
            
            var updatingRetrospect = retrospect
            updatingRetrospect.isPinned.toggle()
            let updatedRetrospect = try await retrospectStorage.update(from: retrospect, to: updatingRetrospect)
            updateRetrospects(by: updatedRetrospect)
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    func finishRetrospect(_ retrospect: Retrospect) async {
        do {
            var updatingRetrospect = retrospect
            updatingRetrospect.summary = try await retrospectAssistantProvider.requestSummary(for: retrospect.chat)
            updatingRetrospect.status = .finished
            let updatedRetrospect = try await retrospectStorage.update(from: retrospect, to: updatingRetrospect)
            updateRetrospects(by: updatedRetrospect)
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    func deleteRetrospect(_ retrospect: Retrospect) async {
        do {
            try await retrospectStorage.delete(contentsOf: [retrospect])
            retrospects.removeAll(where: { $0.id == retrospect.id })
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    func syncWithRetrospectStorage() async {
        do {
            for previousRetrospect in previousRetrospects {
                if let updatingRetrospect = retrospects.first(where: { $0.id == previousRetrospect.id }) {
                    _ = try await retrospectStorage.update(from: previousRetrospect, to: updatingRetrospect)
                }
            }
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    // MARK: Support retrospect creation
    
    private func createNewRetrospect() async throws -> Retrospect {
        guard isCreationAvailable else { throw Error.reachInProgressLimit }
        
        var newRetrospect = Retrospect(userID: userID)
        let initialAssistentMessage = try await requestInitialAssistentMessage(for: newRetrospect)
        newRetrospect.append(contentsOf: [initialAssistentMessage])
        guard let addedRetrospect = try await retrospectStorage.add(contentsOf: [newRetrospect]).first
        else { throw Error.creationFailed }
        
        return addedRetrospect
    }
    
    private func requestInitialAssistentMessage(for retrospect: Retrospect) async throws -> Message {
        let emptyUserMessage = Message(retrospectID: retrospect.id, role: .user, content: "")
        let initialAssistentMessage = try await retrospectAssistantProvider.requestAssistantMessage(
            for: [emptyUserMessage]
        )
        return initialAssistentMessage
    }
    
    // MARK: Support retrospect fetching
    
    private func retrospectFetchRequest(for kind: Retrospect.Kind) -> PersistFetchRequest<Retrospect> {
        PersistFetchRequest<Retrospect>(
            predicate: kind.predicate(for: userID),
            sortDescriptors: [CustomSortDescriptor(key: "createdAt", ascending: false)],
            fetchLimit: kind.fetchLimit
        )
    }
    
    // MARK: Manage retrospects
    
    private var isCreationAvailable: Bool {
        retrospects.filter({ $0.status != .finished }).count < Numerics.inProgressLimit
    }
    
    private var isPinAvailable: Bool {
        retrospects.filter({ $0.isPinned }).count < Numerics.pinLimit
    }
    
    private func updateRetrospects(by retrospect: Retrospect) {
        guard let targetIndex = retrospects.firstIndex(where: { $0.id == retrospect.id }) else { return }
        
        retrospects.remove(at: targetIndex)
        retrospects.insert(retrospect, at: targetIndex)
    }
}

// MARK: - MessageManagerListener conformance

extension RetrospectManager: RetrospectChatManagerListener {
    func didUpdateRetrospect(_ retrospectChatManageable: RetrospectChatManageable, retrospect: Retrospect) {
        guard let matchingIndex = retrospects.firstIndex(where: { $0.id == retrospect.id })
        else { return }
        
        previousRetrospects.insert(retrospects[matchingIndex])
        retrospects[matchingIndex] = retrospect
    }
    
    func shouldTogglePin(_ retrospectChatManageable: RetrospectChatManageable, retrospect: Retrospect) -> Bool {
        isPinAvailable
    }
}

// MARK: - Error

fileprivate extension RetrospectManager {
    enum Error: LocalizedError {
        case creationFailed
        case reachInProgressLimit
        case reachPinLimit
        
        var errorDescription: String? {
            switch self {
            case .creationFailed:
                "회고를 생성하는데 실패했습니다."
            case .reachInProgressLimit:
                "회고는 최대 2개까지 진행할 수 있습니다. 새로 생성하려면 기존의 회고를 끝내주세요."
            case .reachPinLimit:
                "회고는 최대 2개까지 고정할 수 있습니다. 다른 회고의 고정을 풀어주세요."
            }
        }
    }
}

// MARK: - Constant

fileprivate extension RetrospectManager {
    enum Numerics {
        static let pinLimit = 2
        static let inProgressLimit = 2
    }
}
