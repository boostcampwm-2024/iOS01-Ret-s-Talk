//
//  MessageManagerTests.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/20/24.
//

import XCTest

final class MessageManagerTests: XCTestCase {
    private var messageManager: MessageManageable?
    private var testableMessages: [Message] = [
        Message(role: .assistant, content: "오늘은 무엇을 하셨나요?", createdAt: Date() + 6),
        Message(role: .user, content: "오늘은 공부를 했어요", createdAt: Date() + 5),
        Message(role: .assistant, content: "무슨 공부를 하셨나요?", createdAt: Date() + 4),
        Message(role: .user, content: "수능 공부를 했습니다.", createdAt: Date() + 3),
        Message(role: .user, content: "무슨 과목을 하셨나요?", createdAt: Date() + 2),
        Message(role: .user, content: "영어를 했어요", createdAt: Date() + 1),
        Message(role: .user, content: "Hello", createdAt: Date()),
    ]
    
    // MARK: Set up
    
    override func setUp() {
        super.setUp()
        
        let persistent = MockMessageStore()
        persistent.messages = testableMessages
        
        messageManager = MessageManager(
            retrospectID: UUID(),
            messageManagerListener: MockRetrospectManager(),
            persistent: persistent
        )
    }
    
    func test_fetchMessage_메시지를_불러올_수_있는가() async throws {
        let messageManager = try XCTUnwrap(messageManager)
        
        try await messageManager.fetchMessages(offset: 0, amount: 2)
        
        XCTAssertEqual(messageManager.messages.count, 2)
    }
    
    func test_fetchMessage_데이터를_추가로_불러올_수_있는가() async throws {
        let messageManager = try XCTUnwrap(messageManager)
        
        try await messageManager.fetchMessages(offset: 0, amount: 2)
        try await messageManager.fetchMessages(offset: 2, amount: 2)
        
        XCTAssertEqual(messageManager.messages.count, 4)
    }
    
    func test_fetchMessage_데이터를_순서대로_불러오는가() async throws {
        let messageManager = try XCTUnwrap(messageManager)
        
        try await messageManager.fetchMessages(offset: 0, amount: 2)
        
        XCTAssertEqual(messageManager.messages.first?.content, "오늘은 무엇을 하셨나요?")
    }
}
