//
//  RetrospectManagerTests.swift
//  RetsTalkTests
//
//  Created by KimMinSeok on 11/24/24.
//

import XCTest

final class RetrospectManagerTests: XCTestCase {
    private var retrospectManager: RetrospectManageable?
    
    // MARK: Set up
    
    override func setUp() {
        super.setUp()
        
        retrospectManager = RetrospectManager(
            userID: UUID(),
            retrospectStorage: MockRetrospectStore(),
            retrospectAssistantProvider: MockRetrospectAssistantProvider()
        )
    }
    
    override func tearDown() {
        MockRetrospectStore.fetchHadler = nil
        MockRetrospectAssistantProvider.requestAssistantMessageHandler = nil
        MockRetrospectAssistantProvider.requestSummaryHandler = nil
        
        super.tearDown()
    }
    
    // MARK: Creation tests
    
    func test_회고_생성_성공으로_회고_대화_매니저를_생성하는지() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        MockRetrospectStore.fetchHadler = { _ in
            []
        }
        
        let newRetrospectChatManager = await retrospectManager.createRetrospect()
        let errorOccured = await retrospectManager.errorOccurred
        
        XCTAssertNotNil(newRetrospectChatManager)
        XCTAssertNil(errorOccured)
    }
    
    func test_회고_진행중인_회고_한도로_생성_에러를_생성하는지() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        MockRetrospectStore.fetchHadler = { _ in
            [
                Retrospect(userID: UUID(), status: .inProgress(.waitingForUserInput)),
                Retrospect(userID: UUID(), status: .inProgress(.waitingForUserInput)),
            ]
        }
        await retrospectManager.fetchRetrospects(of: [.inProgress])
        
        let newRetrospectChatManager = await retrospectManager.createRetrospect()
        let errorOccured = await retrospectManager.errorOccurred
        
        XCTAssertNil(newRetrospectChatManager)
        XCTAssertNotNil(errorOccured)
    }
    
    // MARK: Fetch tests
    
    func test_연속해서_회고를_가져와서_잘_저장하는지() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        MockRetrospectStore.fetchHadler = { _ in
            [Retrospect(userID: UUID(), status: .finished)]
        }
        
        await retrospectManager.fetchRetrospects(of: [.finished])
        await retrospectManager.fetchRetrospects(of: [.finished])
        
        let retrospects = await retrospectManager.retrospects
        let errorOccured = await retrospectManager.errorOccurred
        XCTAssertEqual(retrospects.count, 2)
        XCTAssertNil(errorOccured)
    }
    
    func test_중복되는_회고를_포함하지_않도록_처리하는지() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        let uniqueRetrospect = Retrospect(userID: UUID(), status: .finished)
        MockRetrospectStore.fetchHadler = { _ in
            [uniqueRetrospect, uniqueRetrospect]
        }
        
        await retrospectManager.fetchRetrospects(of: [.finished])
        
        let retrospects = await retrospectManager.retrospects
        let errorOccured = await retrospectManager.errorOccurred
        XCTAssertEqual(retrospects.count, 1)
        XCTAssertNil(errorOccured)
    }
    
    // MARK: Update tests
    
    func test_회고_고정_가능한_경우_상태_변경이_반영되는지() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        let sourceRetrospect = Retrospect(userID: UUID(), status: .finished, isPinned: false)
        MockRetrospectStore.fetchHadler = { _ in
            [sourceRetrospect]
        }
        await retrospectManager.fetchRetrospects(of: [.finished])
        
        await retrospectManager.togglePinRetrospect(sourceRetrospect)
        
        let retrospects = await retrospectManager.retrospects
        let errorOccured = await retrospectManager.errorOccurred
        XCTAssertNotEqual(retrospects.first?.isPinned, sourceRetrospect.isPinned)
        XCTAssertNil(errorOccured)
    }
    
    func test_회고_고정_한도에_걸려_상태_변경이_안되게_막는지() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        let unpinnedRetrospect = Retrospect(userID: UUID(), status: .finished, isPinned: false)
        MockRetrospectStore.fetchHadler = { _ in
            [
                Retrospect(userID: UUID(), status: .finished, isPinned: true),
                Retrospect(userID: UUID(), status: .finished, isPinned: true),
                unpinnedRetrospect,
            ]
        }
        await retrospectManager.fetchRetrospects(of: [.finished])
        
        await retrospectManager.togglePinRetrospect(unpinnedRetrospect)
        
        let errorOccured = await retrospectManager.errorOccurred
        XCTAssertNotNil(errorOccured)
    }
    
    func test_회고_끝내는_경우_상태_변경이_반영되는지() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        let inProgressRetrospect = Retrospect(userID: UUID(), status: .inProgress(.waitingForUserInput))
        let retrospectSummary = "회고 요약"
        MockRetrospectStore.fetchHadler = { _ in
            [inProgressRetrospect]
        }
        MockRetrospectAssistantProvider.requestSummaryHandler = { _ in
            retrospectSummary
        }
        await retrospectManager.fetchRetrospects(of: [.finished])
        
        await retrospectManager.finishRetrospect(inProgressRetrospect)
        
        let retrospects = await retrospectManager.retrospects
        let errorOccured = await retrospectManager.errorOccurred
        XCTAssertEqual(retrospects.first?.status, .finished)
        XCTAssertEqual(retrospects.first?.summary, retrospectSummary)
        XCTAssertNil(errorOccured)
    }
    
    // MARK: Deletion test
    
    func test_회고_삭제를_성공적으로_수행하는지() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        let targetRetrospect = Retrospect(userID: UUID(), status: .finished)
        MockRetrospectStore.fetchHadler = { _ in
            [
                Retrospect(userID: UUID(), status: .finished, isPinned: true),
                Retrospect(userID: UUID(), status: .inProgress(.waitingForUserInput)),
                targetRetrospect,
                Retrospect(userID: UUID(), status: .finished),
            ]
        }
        await retrospectManager.fetchRetrospects(of: [.pinned, .inProgress, .finished])
        
        await retrospectManager.deleteRetrospect(targetRetrospect)
        
        let retrospects = await retrospectManager.retrospects
        let errorOccured = await retrospectManager.errorOccurred
        XCTAssertFalse(retrospects.contains(targetRetrospect))
        XCTAssertNil(errorOccured)
    }
}
