//
//  AssistantMessageProvider.swift
//  RetsTalk
//
//  Created on 11/19/24.
//

protocol AssistantMessageProvidable: Actor {
    func requestAssistantMessage(for chat: [Message]) async throws -> Message
}
