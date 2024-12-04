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
    private var retrospectStorage: Persistable
    private let retrospectAssistantProvider: RetrospectAssistantProvidable
    
    private(set) var retrospects: [Retrospect]
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
        
        retrospects = []
    }
    
    // MARK: RetrospectManageable conformance
    
    func createRetrospect() async -> RetrospectChatManageable? {
        do {
            let newRetrospect = try await createNewRetrospect()
            retrospects.append(newRetrospect)
            let retrospectChatManager = RetrospectChatManager(
                retrospect: newRetrospect,
                messageStorage: retrospectStorage,
                assistantMessageProvider: retrospectAssistantProvider,
                retrospectChatManagerListener: self
            )
            errorOccurred = nil
            return retrospectChatManager
        } catch {
            errorOccurred = error
            return nil
        }
    }
    
    func retrospectChatManager(of retrospect: Retrospect) -> (any RetrospectChatManageable)? {
        guard let retrospect = retrospects.first(where: { $0.id == retrospect.id })
        else {
            errorOccurred = Error.invalidRetrospect
            return nil
        }
        
        let retrospectChatManager = RetrospectChatManager(
            retrospect: retrospect,
            messageStorage: retrospectStorage,
            assistantMessageProvider: retrospectAssistantProvider,
            retrospectChatManagerListener: self
        )
        errorOccurred = nil
        return retrospectChatManager
    }
    
    func fetchRetrospects(of kindSet: Set<Retrospect.Kind>) {
        do {
            for kind in kindSet {
                let request = retrospectFetchRequest(for: kind)
                let fetchedRetrospects = try retrospectStorage.fetch(by: request)
                for retrospect in fetchedRetrospects where !retrospects.contains(retrospect) {
                    retrospects.append(retrospect)
                }
            }
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    func fetchPreviousRetrospects() async {
        do {
            let request = previousRetrospectFetchRequest(amount: Numerics.retrospectFetchAmount)
            let fetchedRetrospects = try retrospectStorage.fetch(by: request)
            retrospects.append(contentsOf: fetchedRetrospects)
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    func fetchRetrospectsCount() async -> (totalCount: Int, monthlyCount: Int)? {
        do {
            let totalFetchRequest = PersistFetchRequest<Retrospect>(fetchLimit: Numerics.fetchTotalDataCountLimit)
            let monthlyFetchRequest = monthlyRetrospectCountFetchRequest()
            
            let totalCount = try retrospectStorage.fetchDataCount(by: totalFetchRequest)
            let monthlyCount = try retrospectStorage.fetchDataCount(by: monthlyFetchRequest)
            
            errorOccurred = nil
            return (totalCount, monthlyCount)
        } catch {
            errorOccurred = error
            return nil
        }
    }
    
    func togglePinRetrospect(_ retrospect: Retrospect) {
        do {
            guard retrospect.isPinned || isPinAvailable else { throw Error.reachPinLimit }
            
            var updatingRetrospect = retrospect
            updatingRetrospect.isPinned.toggle()
            let updatedRetrospect = try retrospectStorage.update(from: retrospect, to: updatingRetrospect)
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
            let updatedRetrospect = try retrospectStorage.update(from: retrospect, to: updatingRetrospect)
            updateRetrospects(by: updatedRetrospect)
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    func deleteRetrospect(_ retrospect: Retrospect) {
        do {
            try retrospectStorage.delete(contentsOf: [retrospect])
            retrospects.removeAll(where: { $0.id == retrospect.id })
            errorOccurred = nil
        } catch {
            errorOccurred = error
        }
    }
    
    func replaceRetrospectStorage(_ newRetrospectStorage: Persistable) {
        retrospectStorage = newRetrospectStorage
    }
    
    // MARK: Support retrospect creation
    
    private func createNewRetrospect() async throws -> Retrospect {
        guard isCreationAvailable else { throw Error.reachInProgressLimit }
        
        var newRetrospect = Retrospect(userID: userID)
        let initialAssistentMessage = try await requestInitialAssistentMessage(for: newRetrospect)
        newRetrospect.append(contentsOf: [initialAssistentMessage])
        guard let addedRetrospect = try retrospectStorage.add(contentsOf: [newRetrospect]).first
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
    
    private func previousRetrospectFetchRequest(amount: Int) -> PersistFetchRequest<Retrospect> {
        let recentDateSorting = CustomSortDescriptor(key: Texts.retrospectSortKey, ascending: false)
        let lastRetrospectCreatedDate = retrospects.last?.createdAt ?? Date()
        let predicate = Retrospect.Kind.predicate(.previous(lastRetrospectCreatedDate))(for: userID)
        return PersistFetchRequest<Retrospect>(
            predicate: predicate,
            sortDescriptors: [recentDateSorting],
            fetchLimit: Retrospect.Kind.previous(lastRetrospectCreatedDate).fetchLimit
        )
    }
    
    private func monthlyRetrospectCountFetchRequest() -> PersistFetchRequest<Retrospect> {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())),
              let nextMonth = calendar.date(byAdding: DateComponents(month: 1), to: currentMonth)
        else {
            return PersistFetchRequest<Retrospect>(fetchLimit: 0)
        }
        
        let predicate = Retrospect.Kind.predicate(.monthly(from: currentMonth, to: nextMonth))(for: userID)
        return PersistFetchRequest(
            predicate: predicate,
            fetchLimit: Retrospect.Kind.monthly(from: currentMonth, to: nextMonth).fetchLimit
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
        guard let matchingIndex = retrospects.firstIndex(where: { $0.id == retrospect.id }) else { return }
        
        retrospects[matchingIndex] = retrospect
    }
}

// MARK: - RetrospectChatManagerListener conformance

extension RetrospectManager: RetrospectChatManagerListener {
    func didUpdateRetrospect(_ retrospectChatManageable: RetrospectChatManageable, retrospect: Retrospect) throws {
        guard let matchingIndex = retrospects.firstIndex(where: { $0.id == retrospect.id })
        else { return }
        
        let updatedRetrospect = try retrospectStorage.update(from: retrospects[matchingIndex], to: retrospect)
        
        retrospects[matchingIndex] = updatedRetrospect
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
        case invalidRetrospect
        
        var errorDescription: String? {
            switch self {
            case .creationFailed:
                "회고를 생성하는데 실패했습니다."
            case .reachInProgressLimit:
                "회고는 최대 2개까지 진행할 수 있습니다. 새로 생성하려면 기존의 회고를 끝내주세요."
            case .reachPinLimit:
                "회고는 최대 2개까지 고정할 수 있습니다. 다른 회고의 고정을 풀어주세요."
            case .invalidRetrospect:
                "존재하지 않는 회고입니다."
            }
        }
    }
}

// MARK: - Constant

fileprivate extension RetrospectManager {
    enum Numerics {
        static let fetchTotalDataCountLimit = 0
        static let pinLimit = 2
        static let inProgressLimit = 2
        static let retrospectFetchAmount = 2
    }
    
    enum Texts {
        static let retrospectFinished = "retrospectFinished"
        static let retrospectSortKey = "createdAt"
    }
}
