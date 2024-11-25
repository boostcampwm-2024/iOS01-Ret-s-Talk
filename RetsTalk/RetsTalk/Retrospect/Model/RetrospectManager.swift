//
//  RetrospectManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Foundation
import Combine

final class RetrospectManager: RetrospectManageable {
    private let userID: UUID
    private var retrospects: [Retrospect] {
        didSet { retrospectsSubject.send(retrospects) }
    }
    private(set) var retrospectsSubject: CurrentValueSubject<[Retrospect], Never>
    private let retrospectStorage: Persistable
    private let assistantMessageProvider: AssistantMessageProvidable
    
    init(
        userID: UUID,
        retrospectStorage: Persistable,
        assistantMessageProvider: AssistantMessageProvidable
    ) {
        self.userID = userID
        self.retrospects = []
        self.retrospectsSubject = CurrentValueSubject(retrospects)
        self.retrospectStorage = retrospectStorage
        self.assistantMessageProvider = assistantMessageProvider
    }
    
    func fetchRetrospects(offset: Int, amount: Int) async throws {
        let finishedRecentRequest = finishedRecentRetrospectFetchRequest(offset: offset, amount: amount)
        let finishedRecentEntities = try await retrospectStorage.fetch(by: finishedRecentRequest)
        retrospects.append(contentsOf: finishedRecentEntities)
    }
    
    func fetchinitRetrospects(offset: Int, amount: Int) async throws {
        let isPinnedRequest = isPinnedRetrospectFetchRequest()
        let isPinnedEntities = try await retrospectStorage.fetch(by: isPinnedRequest)
        
        let isProgressRequest = isProgressRetrospectFetchRequest()
        let isProgressEntities = try await retrospectStorage.fetch(by: isProgressRequest)
        
        let finishedRecentRequest = finishedRecentRetrospectFetchRequest(offset: offset, amount: amount)
        let finishedRecentEntities = try await retrospectStorage.fetch(by: finishedRecentRequest)
        
        let resultRetrospects = [isPinnedEntities, isProgressEntities, finishedRecentEntities]
            .flatMap { $0 }
        retrospects.append(contentsOf: resultRetrospects)
    }
    
    func create() -> RetrospectChatManageable {
        let retropsect = Retrospect(userID: userID)
        let retrospectChatManager = RetrospectChatManager(
            retrospect: retropsect,
            persistent: retrospectStorage,
            assistantMessageProvider: assistantMessageProvider,
            retrospectChatManagerListener: self
        )
        retrospects.append(retropsect)
        
        return retrospectChatManager
    }
    
    func update(_ retrospect: Retrospect) async throws {
        
    }
    
    func delete(_ retrospect: Retrospect) async throws {
        
    }
}

// MARK: - ChatManager Create FetchRequest

extension RetrospectManager {
    private func isPinnedRetrospectFetchRequest() -> PersistfetchRequest<Retrospect> {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "userID = %@", argumentArray: [userID]),
            NSPredicate(format: "isPinned = %@", argumentArray: [true]),
        ])
        let sortDescriptors = NSSortDescriptor(key: "createdAt", ascending: false)
        
        let request = PersistfetchRequest<Retrospect>(
            predicate: predicate,
            sortDescriptors: [sortDescriptors],
            fetchLimit: Metrics.isPinnedFetchAmount
        )
        
        return request
    }
    
    private func isProgressRetrospectFetchRequest() -> PersistfetchRequest<Retrospect> {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "userID = %@", argumentArray: [userID]),
            NSPredicate(format: "status != %@", argumentArray: [Texts.finishedStatus]),
        ])
        let sortDescriptors = NSSortDescriptor(key: "createdAt", ascending: false)
        
        let request = PersistfetchRequest<Retrospect>(
            predicate: predicate,
            sortDescriptors: [sortDescriptors],
            fetchLimit: Metrics.isProgressFetchAmount
        )
        
        return request
    }
    
    private func finishedRecentRetrospectFetchRequest(offset: Int, amount: Int) -> PersistfetchRequest<Retrospect> {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "userID = %@", argumentArray: [userID]),
            NSPredicate(format: "status = %@", argumentArray: [Texts.finishedStatus]),
        ])
        let sortDescriptors = NSSortDescriptor(key: "createdAt", ascending: false)
        
        let request = PersistfetchRequest<Retrospect>(
            predicate: predicate,
            sortDescriptors: [sortDescriptors],
            fetchLimit: amount,
            fetchOffset: offset
        )
        
        return request
    }
}


// MARK: - MessageManagerListener conformance

extension RetrospectManager: RetrospectChatManagerListener {
    func didFinishRetrospect(_ retrospectChatManager: RetrospectChatManageable) {
        guard let index = retrospects.firstIndex(where: { $0.id == retrospectChatManager.retrospectSubject.value.id })
        else { return }
        
        retrospects[index].status = .finished
    }
    
    func didChangeStatus(
        _ retrospectChatManager: RetrospectChatManageable,
        to status: Retrospect.Status
    ) {
        guard let index = retrospects.firstIndex(where: { $0.id == retrospectChatManager.retrospectSubject.value.id })
        else { return }
        
        retrospects[index].status = status
    }
}

// MARK: - Constant

extension RetrospectManager {
    enum Metrics {
        static let isPinnedFetchAmount = 2
        static let isProgressFetchAmount = 2
    }
    
    enum Texts {
        static let finishedStatus = "retrospectFinished"
    }
}
