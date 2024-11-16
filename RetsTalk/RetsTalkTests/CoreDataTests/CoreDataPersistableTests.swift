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

    func test_add결과_예상과_동일() throws {
        // given
        let content = "Hello"

        // when
        guard let message = try addDummyEntity(content: content) else {
            XCTFail("add 결과가 올바르지 않아서 nil 반환")
            return
        }

        // then
        XCTAssertEqual(message.content, content)
    }

    func test_fetch가_엔티티_수만큼_반환() async throws {
        // given
        let repeatingNumber = 5
        try addDummyEntities(repeating: repeatingNumber)

        // when
        let fetchRequest = MessageTestEntity.fetchRequest()
        guard let fetchedMessages = try await coreDataManager?.fetch(by: fetchRequest) else { return }

        // then
        XCTAssertEqual(fetchedMessages.count, repeatingNumber)
    }

    func test_update를_통해_엔티티_수정() throws {
        // given
        guard let entity = try addDummyEntity(content: "Hello") else {
            XCTFail("add 결과가 올바르지 않아서 nil 반환")
            return
        }

        // when
        let updatedEntity = try coreDataManager?.update(entity: entity) { entity in
            entity.content = "World"
        }

        // then
        guard let updatedEntity else { return }

        XCTAssertEqual(updatedEntity.content, "World")
    }

    func test_delete_단일_객체() async throws {
        // given
        let content = "Hello"
        guard let entity = try addDummyEntity(content: content) else {
            XCTFail("add 결과가 올바르지 않아서 nil 반환")
            return
        }

        // when
        try coreDataManager?.delete(entity: entity)

        // then
        let fetchRequest = MessageTestEntity.fetchRequest()
        guard let fetchedMessages = try await coreDataManager?.fetch(by: fetchRequest) else { return }

        XCTAssertTrue(fetchedMessages.isEmpty)
    }

    func test_delete_복수_객체() async throws {
        // given
        let repeatingNumber = 5
        let fetchLimit = 2
        try addDummyEntities(repeating: repeatingNumber)

        // when
        let fetchRequest = MessageTestEntity.fetchRequest()
        fetchRequest.fetchLimit = fetchLimit
        try await coreDataManager?.delete(by: fetchRequest)

        // then
        guard let fetchedMessages = try await coreDataManager?.fetch(by: fetchRequest) else { return }

        XCTAssertEqual(fetchedMessages.count, repeatingNumber - fetchLimit)
    }

    // MARK: Helper

    private func addDummyEntity(content: String) throws -> MessageEntity? {
        let message = try coreDataManager?.add(entityProvider: { context in
            let message = MessageTestEntity(context: context)
            message.content = content
            message.createdAt = Date()
            message.isUser = true
            return message
        })
        return message as? MessageEntity
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
