//
//  RetrospectManageable.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

protocol RetrospectManageable {
    var retrospects: [Retrospect] { get }
    
    func fetchRetrospects(offset: Int, amount: Int)
    func create()
    func update(_ retrospect: Retrospect)
    func delete(_ retrospect: Retrospect)
}
