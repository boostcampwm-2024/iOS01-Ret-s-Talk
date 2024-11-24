//
//  RetrospectManageable.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import Combine

protocol RetrospectManageable {
    var retrospectsSubject: CurrentValueSubject<[Retrospect], Never> { get }
    
    func fetchRetrospects(offset: Int, amount: Int)
    func create() -> RetrospectChatManageable
    func update(_ retrospect: Retrospect)
    func delete(_ retrospect: Retrospect)
}
