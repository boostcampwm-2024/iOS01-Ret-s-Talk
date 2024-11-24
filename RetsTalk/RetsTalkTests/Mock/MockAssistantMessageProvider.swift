//
//  MockAssistantMessageProvider.swift
//  RetsTalkTests
//
//  Created by Byeongjo Koo on 11/21/24.
//

import XCTest

struct MockAssistantMessageProvider: AssistantMessageProvidable {
    nonisolated(unsafe) static var requestAssistantMessageHandler: (([Message]) throws -> Message)?

    func requestAssistantMessage(for chat: [Message]) async throws -> Message {
        guard let handler = MockAssistantMessageProvider.requestAssistantMessageHandler
        else {
            XCTFail("요청 처리 핸들러가 설정되지 않았습니다.")
            return Message(role: .assistant, content: "", createdAt: Date())
        }
        
        return try handler(chat)
    }
}
