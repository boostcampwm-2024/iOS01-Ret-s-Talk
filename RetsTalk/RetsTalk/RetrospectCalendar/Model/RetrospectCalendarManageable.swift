//
//  RetrospectCalendarManageable.swift
//  RetsTalk
//
//  Created by KimMinSeok on 12/5/24.
//

import Combine

@RetrospectActor
protocol RetrospectCalendarManageable: Sendable {
    var retrospects: [Retrospect] { get }
    var retrospectsPublisher: AnyPublisher<[Retrospect], Never> { get }
    var errorPublisher: AnyPublisher<Error, Never> { get }
    
    func retrospectChatManager(of retrospect: Retrospect) -> RetrospectChatManageable?
    func fetchRetrospects(of kindList: [Retrospect.Kind])
    func finishRetrospect(_ retrospect: Retrospect) async
}
