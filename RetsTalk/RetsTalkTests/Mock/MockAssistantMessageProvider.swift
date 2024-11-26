//
//  MockAssistantMessageProvider.swift
//  RetsTalkTests
//
//  Created by Byeongjo Koo on 11/21/24.
//

import XCTest

actor MockAssistantMessageProvider: AssistantMessageProvidable {
    static var requestAssistantMessageHandler: (([Message]) async throws -> Message)?

    func requestAssistantMessage(for chat: [Message]) async throws -> Message {
        guard let handler = MockAssistantMessageProvider.requestAssistantMessageHandler
        else {
            XCTFail("요청 처리 핸들러가 설정되지 않았습니다.")
            return Message(retrospectID: UUID(), role: .assistant, content: "", createdAt: Date())
        }
        
        return try await handler(chat)
    }
}
