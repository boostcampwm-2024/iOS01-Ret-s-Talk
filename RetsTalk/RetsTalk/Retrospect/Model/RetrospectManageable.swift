//
//  RetrospectManageable.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import Combine

protocol RetrospectManageable {
    var retrospectsSubject: CurrentValueSubject<[Retrospect], Never> { get }
    
    func fetchRetrospects(offset: Int, amount: Int) async throws
    func create() async throws -> RetrospectChatManageable
    func update(_ retrospect: Retrospect) async throws
    func delete(_ retrospect: Retrospect) async throws
}
