//
//  RetrospectManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Foundation

final class RetrospectManager: RetrospectManageable {
    private(set) var retrospects: [Retrospect] = []
    
    fileprivate var messageMap: [UUID: MessageManageable] = [:]
    
    func fetchRetrospects(offset: Int, mount: Int) {
        
    }
    
    func create() {
        let retropsect = Retrospect(author: User(nickname: "alstjr"))
        
        let messageManager = MessageManager(
            retrospectID: retropsect.id,
            messageManagerListener: self
        )
        
        retrospects.append(retropsect)
        messageMap[retropsect.id] = messageManager
    }
    
    func delete(_ retrospect: Retrospect) {
        
    }
}
