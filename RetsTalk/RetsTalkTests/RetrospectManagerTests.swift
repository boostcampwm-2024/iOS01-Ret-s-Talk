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
        
        retrospectStore = MockRetrospectStore(retrospects: testableMessages)
        
        retrospectManager = RetrospectManager(
            userID: UUID(),
            retrospectStorage: retrospectStore ?? MockRetrospectStore(retrospects: []),
            assistantMessageProvider: MockAssistantMessageProvider()
        )
    }
    
    func test_회고를_불러올_수_있는가() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        
        try await retrospectManager.fetchRetrospects(offset: 0, amount: 2)
        
        let retrospectResult = retrospectManager.retrospectsSubject.value
        XCTAssertEqual(retrospectResult.count, 2)
    }
    
    func test_추가로_회고를_불러올_수_있는가() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        
        try await retrospectManager.fetchRetrospects(offset: 0, amount: 2)
        try await retrospectManager.fetchRetrospects(offset: 0, amount: 2)
        
        let retrospectResult = retrospectManager.retrospectsSubject.value
        XCTAssertEqual(retrospectResult.count, 4)
    }
    
    func test_가지고있는_회고보다_많은_요청을_하면_최대로_가져오는가() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        
        try await retrospectManager.fetchRetrospects(offset: 0, amount: 10)
        
        let retrospectResult = retrospectManager.retrospectsSubject.value
        XCTAssertEqual(retrospectResult.count, 5)
    }
    
    func test_회고를_추가할_수_있는가() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        
        _ = try await retrospectManager.create()
        
        XCTAssertEqual(retrospectManager.retrospectsSubject.value.count, 1)
    }
    
    func test_회고를_추가하면_persistent에_추가가_되는지() async throws {
        let retrospectManager = try XCTUnwrap(retrospectManager)
        let retrospectStore = try XCTUnwrap(retrospectStore)
        
        _ = try await retrospectManager.create()
        
        XCTAssertEqual(retrospectStore.retrospects.count, 6)
    }
}
