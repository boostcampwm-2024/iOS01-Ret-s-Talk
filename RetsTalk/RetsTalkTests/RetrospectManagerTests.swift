//
//  RetrospectManagerTests.swift
//  RetsTalkTests
//
//  Created by KimMinSeok on 11/24/24.
//

import XCTest

final class RetrospectManagerTests: XCTestCase {
    private var retrospectManager: RetrospectManager?
    private let sharedUserID = UUID()
    
    private var testableMessages: [Retrospect] = []
    
    override func setUp() {
        super.setUp()
        
        testableMessages = [
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
        ]
        
        retrospectManager = RetrospectManager(
            userID: UUID(),
            retrospectStorage: MockRetrospectStore(retrospects: testableMessages),
            assistantMessageProvider: MockAssistantMessageProvider()
        )
    }
    
    func test_회고를_불러올_수_있는가() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        
        try await retrospectManager.fetchRetrospects(offset: 0, amount: 2)
        
        let retrospectResult = retrospectManager.retrospects
        XCTAssertEqual(retrospectResult.count, 2)
    }
    
    func test_추가로_회고를_불러올_수_있는가() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        
        try await retrospectManager.fetchRetrospects(offset: 0, amount: 2)
        try await retrospectManager.fetchRetrospects(offset: 0, amount: 2)
        
        let retrospectResult = retrospectManager.retrospects
        XCTAssertEqual(retrospectResult.count, 4)
    }
    
    func test_가지고있는_회고보다_많은_요청을_하면_최대로_가져오는가() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        
        try await retrospectManager.fetchRetrospects(offset: 0, amount: 10)
        
        let retrospectResult = retrospectManager.retrospects
        XCTAssertEqual(retrospectResult.count, 5)
    }
}
