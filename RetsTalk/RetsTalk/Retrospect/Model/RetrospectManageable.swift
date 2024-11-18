//
//  RetrospectManageable.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

protocol RetrospectManageable {
    var retrospects: [Retrospect] { get }
    
    func fetchRetrospects(offset: Int, mount: Int)
    func create()
    func delete(_ retrospect: Retrospect)
}
