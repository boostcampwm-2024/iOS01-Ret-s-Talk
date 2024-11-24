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
    private(set) var retrospects: [Retrospect]
    private(set) var retrospectsSubject: CurrentValueSubject<[Retrospect], Never>
    private let retrospectStorage: Persistable
    
    init(userID: UUID, retrospectStorage: Persistable) {
        self.userID = userID
        self.retrospects = []
        self.retrospectsSubject = CurrentValueSubject(retrospects)
        self.retrospectStorage = retrospectStorage
    }
    
    func fetchRetrospects(offset: Int, amount: Int) async throws {
        let predicate = NSPredicate(format: "userID = %@", argumentArray: [userID])
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        let request = PersistfetchRequest<Retrospect>(
            predicate: predicate,
            sortDescriptors: [sortDescriptor],
            fetchLimit: amount,
            fetchOffset: offset
        )
        let fetchedEntities = try await retrospectStorage.fetch(by: request)
        
        retrospects.append(contentsOf: fetchedEntities)
    }
    
    func create() -> RetrospectChatManageable {
        let retropsect = Retrospect(userID: userID)
        let retrospectChatManager = RetrospectChatManager(
            retrospect: retropsect,
            persistent: retrospectStorage,
            assistantMessageProvider: CLOVAStudioManager(urlSession: .shared),
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
