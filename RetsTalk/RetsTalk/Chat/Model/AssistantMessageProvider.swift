//
//  AssistantMessageProvider.swift
//  RetsTalk
//
//  Created on 11/19/24.
//

protocol AssistantMessageProvidable: Sendable {
    func requestAssistantMessage(for retrospect: Retrospect) async throws -> Message
}
