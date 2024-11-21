//
//  RetrospectManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Foundation
import Combine

final class RetrospectManager: RetrospectManageable {
    private(set) var user: User
    private var retrospects: [Retrospect] {
        didSet { retrospectsSubject.send(retrospects) }
    }
    private(set) var retrospectsSubject: CurrentValueSubject<[Retrospect], Never>
    fileprivate var messageManagerMapping: [UUID: MessageManageable]
    
    init(retrospects: [Retrospect]) {
        self.retrospects = retrospects
        self.retrospectsSubject = CurrentValueSubject(retrospects)
        self.messageManagerMapping = [:]
    }
    
    func fetchRetrospects(offset: Int, amount: Int) {
        let predicate = NSPredicate(format: "retrospectID = %@", argumentArray: [user.id])
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        let request = PersistfetchRequest<Message>(
            predicate: predicate,
            sortDescriptors: [sortDescriptor],
            fetchLimit: amount,
            fetchOffset: offset
        )
        
        let fetchedEntities = try await persistent.fetch(by: request)
        
        retrospects.chat.append(contentsOf: fetchedEntities)
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
