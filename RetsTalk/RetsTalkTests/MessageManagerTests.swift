//
//  MessageManagerTests.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/20/24.
//

import XCTest

final class MessageManagerTests: XCTestCase {
    private var messageManager: RetrospectChatManageable?
    
    private var testableMessages: [Message] = [
        Message(retrospectID: UUID(), role: .user, content: "수능 공부를 했습니다.", createdAt: Date() + 3),
        Message(retrospectID: UUID(), role: .user, content: "오늘은 공부를 했어요", createdAt: Date() + 5),
        Message(retrospectID: UUID(), role: .user, content: "무슨 과목을 하셨나요?", createdAt: Date() + 2),
        Message(retrospectID: UUID(), role: .assistant, content: "오늘은 무엇을 하셨나요?", createdAt: Date() + 6),
        Message(retrospectID: UUID(), role: .assistant, content: "무슨 공부를 하셨나요?", createdAt: Date() + 4),
        Message(retrospectID: UUID(), role: .user, content: "Hello", createdAt: Date()),
        Message(retrospectID: UUID(), role: .user, content: "영어를 했어요", createdAt: Date() + 1),
    ]
    
    // MARK: Set up
    
    override func setUp() {
        super.setUp()
        
        messageManager = RetrospectChatManager(
            retrospect: Retrospect(userID: UUID()),
            persistent: MockMessageStore(messages: testableMessages),
            assistantMessageProvider: MockAssistantMessageProvider(),
            retrospectChatManagerListener: MockRetrospectManager()
        )
    }
    
    override func tearDown() {
        MockAssistantMessageProvider.requestAssistantMessageHandler = nil
        
        super.tearDown()
    }
    
    // MARK: Test for fetch
    
    func test_fetchMessage_메시지를_불러올_수_있는가() async throws {
        let messageManager = try XCTUnwrap(messageManager)
        
        try await messageManager.fetchMessages(offset: 0, amount: 2)
        
        let messageResult = messageManager.retrospectSubject.value.chat
        XCTAssertEqual(messageResult.count, 2)
    }
    
    func test_fetchMessage_많은_메시지를_불러오는가() async throws {
        let messageManager = try XCTUnwrap(messageManager)
        
        try await messageManager.fetchMessages(offset: 0, amount: 5)
        
        let messageResult = messageManager.retrospectSubject.value.chat
        XCTAssertEqual(messageResult.count, 5)
    }
    
    func test_fetchMessage_가지고_있는_부분보다_많은_메시지를_요청하면_최대까지만_불러오는가() async throws {
        let messageManager = try XCTUnwrap(messageManager)
        
        try await messageManager.fetchMessages(offset: 0, amount: 10)
        
        let messageResult = messageManager.retrospectSubject.value.chat
        XCTAssertEqual(messageResult.count, 7)
    }
    
    func test_fetchMessage_데이터를_추가로_불러올_수_있는가() async throws {
        let messageManager = try XCTUnwrap(messageManager)
        
        try await messageManager.fetchMessages(offset: 0, amount: 2)
        try await messageManager.fetchMessages(offset: 2, amount: 2)
        
        let messageResult = messageManager.retrospectSubject.value.chat
        XCTAssertEqual(messageResult.count, 4)
    }
    
    func test_fetchMessage_데이터를_순서대로_불러오는가() async throws {
        let messageManager = try XCTUnwrap(messageManager)
        
        testableMessages.sort { $0.createdAt < $1.createdAt }
        try await messageManager.fetchMessages(offset: 0, amount: testableMessages.count)
        
        let messageResult = messageManager.retrospectSubject.value.chat
        for (index, testMessage) in testableMessages.enumerated() {
            XCTAssertEqual(messageResult[index].content, testMessage.content)
            XCTAssertEqual(messageResult[index].createdAt, testMessage.createdAt)
        }
    }
    
    func test_fetchMessage_제일_최신에_있는_데이터를_불러오는가() async throws {
        let messageManager = try XCTUnwrap(messageManager)
        
        try await messageManager.fetchMessages(offset: 0, amount: 2)
        
        let messageResult = messageManager.retrospectSubject.value.chat
        XCTAssertEqual(messageResult.first?.content, "Hello")
        XCTAssertEqual(messageResult.last?.content, "영어를 했어요")
    }
    
    // MARK: Test for send
    
    func test_회고_도움_메시지를_받아왔을때_상태_반영을_하는지() async throws {
        let messageManager = try XCTUnwrap(messageManager)
        let userMessage = try XCTUnwrap(testableMessages.randomElement())
        let assistantMessage = Message(
            retrospectID: messageManager.retrospectSubject.value.id,
            role: .assistant,
            content: "응답 테스트 메시지",
            createdAt: Date()
        )
        MockAssistantMessageProvider.requestAssistantMessageHandler = { _ in
            let retrospect = messageManager.retrospectSubject.value
            XCTAssertEqual(retrospect.status, .inProgress(.waitingForResponse))
            return assistantMessage
        }
        
        try await messageManager.send(userMessage)
        
        let retrospect = messageManager.retrospectSubject.value
        XCTAssertEqual(retrospect.status, .inProgress(.waitingForUserInput))
        XCTAssertEqual(retrospect.chat.count, 2)
    }
    
    func test_회고_도움_메시지를_받아오는데_실패한_경우_상태_반영을_하는지() async throws {
        let messageManager = try XCTUnwrap(messageManager)
        let userMessage = try XCTUnwrap(testableMessages.randomElement())
        MockAssistantMessageProvider.requestAssistantMessageHandler = { _ in
            throw CustomError.custom
        }
        
        do {
            try await messageManager.send(userMessage)
            XCTFail("반드시 오류가 전달되어야 합니다.")
        } catch {
            let retrospect = messageManager.retrospectSubject.value
            XCTAssertEqual(retrospect.status, .inProgress(.responseErrorOccurred))
            XCTAssertEqual(retrospect.chat.count, 1)
        }
    }
    
    // MARK: Error for test
    
    enum CustomError: Error {
        case custom
    }
}
