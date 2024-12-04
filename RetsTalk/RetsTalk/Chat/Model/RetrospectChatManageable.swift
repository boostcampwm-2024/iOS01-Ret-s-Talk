//
//  RetrospectChatManageable.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import Combine

@RetrospectActor
protocol RetrospectChatManageable: Sendable {
    var retrospect: Retrospect { get }
    var retrospectPublisher: AnyPublisher<Retrospect, Never> { get }
    var errorPublisher: AnyPublisher<Error, Never> { get }
    
    func sendMessage(_ content: String) async
    func requestAssistantMessage() async
    func fetchPreviousMessages() async
    func endRetrospect()
    func toggleRetrospectPin()
}
