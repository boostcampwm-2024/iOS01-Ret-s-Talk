//
//  MockRetrospectAssistantProvider.swift
//  RetsTalkTests
//
//  Created by Byeongjo Koo on 11/21/24.
//

import XCTest

actor MockRetrospectAssistantProvider: RetrospectAssistantProvidable {
    static var requestAssistantMessageHandler: ((Retrospect) async throws -> Message)?
    static var requestSummaryHandler: (([Message]) async throws -> String)?

    func requestAssistantMessage(for retrosepct: Retrospect) async throws -> Message {
        guard let handler = MockRetrospectAssistantProvider.requestAssistantMessageHandler
        else {
            XCTFail("요청 처리 핸들러가 설정되지 않았습니다.")
            return Message(retrospectID: UUID(), role: .assistant, content: "", createdAt: Date())
        }
        
        return try await handler(retrosepct)
    }
    
    func requestSummary(for chat: [Message]) async throws -> String {
        guard let handler = MockRetrospectAssistantProvider.requestSummaryHandler
        else {
            XCTFail("요청 처리 핸들러가 설정되지 않았습니다.")
            return ""
        }
        
        return try await handler(chat)
    }
}
