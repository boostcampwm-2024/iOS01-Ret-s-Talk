//
//  PersistTests.swift
//  PersistTests
//
//  Created by Byeongjo Koo on 11/19/24.
//

import XCTest

final class PersistTests: XCTestCase {
    private var persistentManager: Persistable?
    
    private let testableContents = [
        "안녕하세요",
        "반갑습니다",
        "오히려좋아",
        "뿌끼먼취킹",
        "다시작성중",
    ]
    
    // MARK: Set up
    
    override func setUp() {
        super.setUp()
    }
    
    // MARK: Test

    func test_추가_연산으로_원하는_엔티티_데이터를_저장할_수_있는지() async throws {
        let persistentManager = try XCTUnwrap(persistentManager)
        let targetContent = try XCTUnwrap(testableContents.randomElement())
        let targetEntity = TestEntity(content: targetContent)
        
        let addedEntities = try await persistentManager.add(contentsOf: [targetEntity])
        
        XCTAssertEqual(addedEntities.first?.content, targetContent)
    }
    
    func test_불러오기_연산으로_특정_엔티티_데이터를_가져올_수_있는지() async throws {
        let persistentManager = try XCTUnwrap(persistentManager)
        try await addMultipleEntities(ofContents: testableContents)
        let targetContent = try XCTUnwrap(testableContents.randomElement())
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "content = %@", argumentArray: [targetContent]),
            NSPredicate(format: "integer = %@", argumentArray: [0]),
        ])
        let request = PersistfetchRequest<TestEntity>(predicate: predicate, fetchLimit: 5)
        let fetchedEntities = try await persistentManager.fetch(by: request)
        
        XCTAssertEqual(fetchedEntities.count, 1)
        XCTAssertEqual(fetchedEntities.first?.content, targetContent)
    }
    
    func test_업데이트_연산으로_기존_엔티티_값을_변경할_수_있는지() async throws {
        let persistentManager = try XCTUnwrap(persistentManager)
        try await addMultipleEntities(ofContents: testableContents)
        let targetContent = try XCTUnwrap(testableContents.randomElement())
        let sourceEntity = TestEntity(content: targetContent)
        let updatingEntity = TestEntity(content: "아파트아파트")
        
        let updatedEntity = try await persistentManager.update(from: sourceEntity, to: updatingEntity)
        
        XCTAssertEqual(updatedEntity.content, updatingEntity.content)
    }
    
    func test_삭제_연산으로_특정_엔티티_데이터를_제거할_수_있는지() async throws {
        let persistentManager = try XCTUnwrap(persistentManager)
        try await addMultipleEntities(ofContents: testableContents)
        let targetContent = try XCTUnwrap(testableContents.randomElement())
        let targetEntity = TestEntity(content: targetContent)
        
        try await persistentManager.delete(contentsOf: [targetEntity])
        
        let allEntities = try await persistentManager.fetch(by: PersistfetchRequest<TestEntity>(fetchLimit: 5))
        XCTAssertEqual(allEntities.count, testableContents.count - 1)
        XCTAssertFalse(allEntities.contains(where: { $0.content == targetContent }))
    }
    
    // MARK: Supporting method
    
    private func addMultipleEntities(ofContents contents: [String]) async throws {
        let persistentManager = try XCTUnwrap(persistentManager)
        _ = try await persistentManager.add(contentsOf: contents.map({ TestEntity(content: $0) }))
    }
}
