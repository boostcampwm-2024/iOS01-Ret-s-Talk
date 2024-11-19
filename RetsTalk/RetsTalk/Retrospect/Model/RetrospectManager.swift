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
    
    }
    
    func delete(_ retrospect: Retrospect) {
        
    }
}
