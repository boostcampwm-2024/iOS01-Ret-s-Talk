//
//  CoreDataPersistableTests.swift
//  RetsTalkTests
//
//  Created by MoonGoon on 11/14/24.
//

import XCTest
import CoreData

final class CoreDataPersistableTests: XCTestCase {
    private var coreDataManager: CoreDataPersistable?

    // MARK: Set up and tear down

    // MARK: Test

    func test_add결과_예상과_동일() async throws {
        // given
        let content: String = "Hello"

        // when
        let message = try addDummyEntity(content: content)
        guard let message = message as? MessageTestEntity else {
            XCTFail("add 결과가 MessageTestEntity 타입이 아님")
            return
        }

        // then
        XCTAssertEqual(message.content, content)
    }

    func test_fetch가_엔티티_수만큼_반환() async throws {
        // given
        let repeatingNumber: Int = 5
        try addDummyEntities(repeating: repeatingNumber)

        // when
        let fetchRequest = MessageTestEntity.fetchRequest()
        guard let fetchedMessages = try await coreDataManager?.fetch(by: fetchRequest) else { return }

        // then
        XCTAssertEqual(fetchedMessages.count, repeatingNumber)
    }

    func test_update를_통해_엔티티_수정() async throws {
        // given
        let entity = try addDummyEntity(content: "Hello")
        guard let entity else {
            XCTFail("add 결과가 MessageTestEntity 타입이 아님")
            return
        }

        // when
        let updatedEntity = try coreDataManager?.update(entity: entity) { entity in
            guard let entity = entity as? MessageTestEntity else { return }

            entity.content = "World"
        }

        // then
        guard let updatedEntity = updatedEntity as? MessageTestEntity else { return }

        XCTAssertEqual(updatedEntity.content, "World")
    }

    func test_delete_단일_객체() async throws {
        // given
        let content: String = "Hello"
        let entity = try addDummyEntity(content: content)
        guard let entity else {
            XCTFail("add 결과가 MessageTestEntity 타입이 아님")
            return
        }

        // when
        try coreDataManager?.delete(entity: entity)

        // then
        let fetchRequest = MessageTestEntity.fetchRequest()
        guard let fetchedMessages = try await coreDataManager?.fetch(by: fetchRequest) else { return }

        XCTAssertEqual(fetchedMessages.count, 0)
    }

    func test_delete_복수_객체() async throws {
        // given
        let repeatingNumber: Int = 5
        let fetchLimit: Int = 2
        try addDummyEntities(repeating: 5)

        // when
        let fetchRequest = MessageTestEntity.fetchRequest()
        fetchRequest.fetchLimit = fetchLimit
        try await coreDataManager?.delete(by: fetchRequest)

        // then
        guard let fetchedMessages = try await coreDataManager?.fetch(by: fetchRequest) else { return }

        XCTAssertEqual(fetchedMessages.count, repeatingNumber - fetchLimit)
    }

    // MARK: Helper

    private func addDummyEntity(content: String) throws -> NSManagedObject? {
        let message = try coreDataManager?.add(entityProvider: { context in
            let message = MessageTestEntity(context: context)
            message.content = content
            message.createdAt = Date()
            message.isUser = true
            return message
        })
        return message
    }

    private func addDummyEntities(repeating: Int) throws {
        for _ in 0..<repeating {
            _ = try coreDataManager?.add(entityProvider: { context in
                let message = MessageTestEntity(context: context)
                message.content = "Hello"
                message.createdAt = Date()
                message.isUser = true
                return message
            })
        }
    }
}
