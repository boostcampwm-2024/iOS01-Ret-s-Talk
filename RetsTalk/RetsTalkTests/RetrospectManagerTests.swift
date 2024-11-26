//
//  RetrospectManagerTests.swift
//  RetsTalkTests
//
//  Created by KimMinSeok on 11/24/24.
//

import XCTest

final class RetrospectManagerTests: XCTestCase {
    private var retrospectManager: RetrospectManageable?
    private let sharedUserID = UUID()
    private var retrospectStore: MockRetrospectStore?
    private var testableRetrospects: [Retrospect] = []
    
    override func setUp() {
        super.setUp()
        
        testableRetrospects = [
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
        ]
        
        retrospectStore = MockRetrospectStore(retrospects: testableRetrospects)
        
        retrospectManager = RetrospectManager(
            userID: UUID(),
            retrospectStorage: retrospectStore ?? MockRetrospectStore(retrospects: []),
            assistantMessageProvider: MockAssistantMessageProvider()
        )
    }
    
    func test_회고를_불러올_수_있는가() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        
        try await retrospectManager.fetchRetrospects(offset: 0, amount: 2)
        
        let retrospects = await retrospectManager.retrospects
        XCTAssertEqual(retrospects.count, 2)
    }
    
    func test_회고를_추가할_수_있는가() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        
        _ = try await retrospectManager.create()
        
        let retrospects = await retrospectManager.retrospects
        XCTAssertEqual(retrospects.count, 1)
    }
}
