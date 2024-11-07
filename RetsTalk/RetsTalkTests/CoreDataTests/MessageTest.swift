//
//  MessageTest.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/6/24.
//

import XCTest
@testable import RetsTalk

final class MessageDataTest: XCTestCase {
    let coreDataMessageStorage = CoreDataMessageStorage()
    
    let testMessage = [Message(role: .assistant, content: "오늘 무엇을 하셨나요", createdAt: Date()),
                       Message(role: .user, content: "공부했어요", createdAt: Date()),
                       Message(role: .assistant, content: "잘하셨네요!", createdAt: Date())]
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
        try coreDataMessageStorage.removeAll()
    }
    
    func test_Save_하나의_메세지가_CoreData에_저장되는지() throws {
        try coreDataMessageStorage.save(testMessage[0])
        
        let coreDataMessage = try coreDataMessageStorage.fetchAll().first
        
        XCTAssertEqual(coreDataMessage?.content, "오늘 무엇을 하셨나요")
    }
    
    func test_Save_여러가지_메세지를_저장하는지() throws {
        try testMessage.forEach { message in
            try coreDataMessageStorage.save(message)
        }
        
        let coreDataMessage = try coreDataMessageStorage.fetchAll()
        
        XCTAssertEqual(coreDataMessage.count, testMessage.count)
    }
}
