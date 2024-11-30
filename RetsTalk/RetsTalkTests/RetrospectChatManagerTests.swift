//
//  RetrospectChatManagerTests.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/20/24.
//

import XCTest

final class RetrospectChatManagerTests: XCTestCase {
    private var retrospectChatManager: RetrospectChatManageable?
    
    // MARK: Set up
    
    override func setUp() async throws {
        try await super.setUp()
        
        retrospectChatManager = await RetrospectActor.run {
            RetrospectChatManager(
                retrospect: Retrospect(userID: UUID()),
                messageStorage: MockMessageStore(),
                assistantMessageProvider: MockRetrospectAssistantProvider(),
                retrospectChatManagerListener: MockRetrospectManager()
            )
        }
    }
    
    override func tearDown() async throws {
        MockRetrospectAssistantProvider.requestAssistantMessageHandler = nil
        
        try await super.tearDown()
    }
    
    // MARK: Send
    
    func test_회고_도움_메시지를_받아왔을때_상태_반영을_하는지() async throws {
        let retrospectChatManager = try XCTUnwrap(retrospectChatManager)
        MockRetrospectAssistantProvider.requestAssistantMessageHandler = { _ in
            let retrospect = await retrospectChatManager.retrospect
            XCTAssertEqual(retrospect.status, .inProgress(.waitingForResponse))
            return Message(retrospectID: retrospect.id, role: .assistant, content: "응답 테스트 메시지")
        }
        
        await retrospectChatManager.sendMessage("안녕하세요.")
        
        let retrospect = await retrospectChatManager.retrospect
        XCTAssertEqual(retrospect.status, .inProgress(.waitingForUserInput))
        XCTAssertEqual(retrospect.chat.count, 2)
    }
    
    func test_회고_도움_메시지를_받아오는데_실패한_경우_상태_반영을_하는지() async throws {
        let retrospectChatManager = try XCTUnwrap(retrospectChatManager)
        MockRetrospectAssistantProvider.requestAssistantMessageHandler = { _ in
            throw TestError.custom
        }

        await retrospectChatManager.sendMessage("실패 !")
        
        let retrospect = await retrospectChatManager.retrospect
        let error = await retrospectChatManager.errorOccurred
        XCTAssertEqual(retrospect.status, .inProgress(.responseErrorOccurred))
        XCTAssertEqual(retrospect.chat.count, 1)
        XCTAssertNotNil(error)
    }
    
    // MARK: Fetch
    
    func test_예전_메시지를_불러올_수_있는가() async throws {
        let retrospectChatManager = try XCTUnwrap(retrospectChatManager)
        
        await retrospectChatManager.fetchPreviousMessages()
        
        let retrospect = await retrospectChatManager.retrospect
        XCTAssertEqual(retrospect.chat.count, 30)
    }
    
    // MARK: Update
    
    func test_회고_종료로_상태를_변경할_수_있는가() async throws {
        let retrospectChatManager = try XCTUnwrap(retrospectChatManager)
        
        await retrospectChatManager.endRetrospect()
        
        let retrospect = await retrospectChatManager.retrospect
        XCTAssertEqual(retrospect.status, .finished)
    }
    
    func test_회고_고정_상태를_변경할_수_있는가() async throws {
        let retrospectChatManager = try XCTUnwrap(retrospectChatManager)
        let previousPinState = await retrospectChatManager.retrospect.isPinned
        
        await retrospectChatManager.toggleRetrospectPin()
        
        let retrospect = await retrospectChatManager.retrospect
        XCTAssertNotEqual(retrospect.isPinned, previousPinState)
    }
}
