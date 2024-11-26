//
//  RetrospectManageable.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

protocol RetrospectManageable: Actor {
    var retrospects: [Retrospect] { get }
    
    func fetchRetrospects(offset: Int, amount: Int) async throws
    func create() async throws -> RetrospectChatManageable
    func update(_ retrospect: Retrospect) async throws
    func delete(_ retrospect: Retrospect) async throws
}
