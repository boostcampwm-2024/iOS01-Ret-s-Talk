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
        let request = createRequest(offset: offset, amount: amount)
        let fetchedEntities = try await retrospectStorage.fetch(by: request)
        
        retrospects.append(contentsOf: fetchedEntities)
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
    
    private func createRequest(offset: Int, amount: Int) -> PersistfetchRequest<Retrospect> {
        let predicate = NSPredicate(format: "userID = %@", argumentArray: [userID])
        let sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: true),
            NSSortDescriptor(key: "status", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false),
        ]
        let request = PersistfetchRequest<Retrospect>(
            predicate: predicate,
            sortDescriptors: sortDescriptors,
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
