//
//  RetrospectManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Foundation
import Combine

final class RetrospectManager: RetrospectManageable {
    private(set) var retrospects: [Retrospect] = []
    private(set) var retrospectsSubject: CurrentValueSubject<[Retrospect], Never>
    let userID: UUID
    
    init(userID: UUID) {
        self.userID = userID
        self.retrospectsSubject = CurrentValueSubject(retrospects)
    }
    
    func fetchRetrospects(offset: Int, amount: Int) {
        
    }
    
    func create() {
        let retropsect = Retrospect(userID: userID)
        let messageManager = RetrospectChatManager(
            retrospect: retropsect,
            persistent: CoreDataManager(name: "RetsTalk", completion: { _ in }),
            assistantMessageProvider: CLOVAStudioManager(urlSession: .shared),
            retrospectChatManagerListener: self
        )
        
        retrospects.append(retropsect)
    }
    
    func update(_ retrospect: Retrospect) {
        
    }
    
    func delete(_ retrospect: Retrospect) {
        
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
