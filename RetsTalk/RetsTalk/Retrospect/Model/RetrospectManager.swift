//
//  RetrospectManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Foundation

final class RetrospectManager: RetrospectManageable {
    private(set) var retrospects: [Retrospect] = []
    fileprivate var messageManagerMapping: [UUID: MessageManageable] = [:]
    
    func fetchRetrospects(offset: Int, amount: Int) {
        
    }
    
    func create() {
        let retropsect = Retrospect(user: User(nickname: "alstjr"))
        let messageManager = MessageManager(
            retrospect: retropsect,
            messageManagerListener: self,
            persistent: CoreDataManager(name: "RetsTalk", completion: { _ in })
        )
        
        retrospects.append(retropsect)
        messageManagerMapping[retropsect.id] = messageManager
    }
    
    func update(_ retrospect: Retrospect) {
        
    }
    
    func delete(_ retrospect: Retrospect) {
        
    }
}

// MARK: - MessageManagerListener conformance

extension RetrospectManager: MessageManagerListener {
    func didFinishRetrospect(_ messageManager: MessageManageable) {
        guard let index = retrospects.firstIndex(where: { $0.id == messageManager.retrospectSubject.value.id })
        else { return }
        
        retrospects[index].status = .finished
    }
    
    func didChangeStatus(_ messageManager: MessageManageable, to status: Retrospect.Status) {
        guard let index = retrospects.firstIndex(where: { $0.id == messageManager.retrospectSubject.value.id })
        else { return }
        
        retrospects[index].status = status
    }
}
