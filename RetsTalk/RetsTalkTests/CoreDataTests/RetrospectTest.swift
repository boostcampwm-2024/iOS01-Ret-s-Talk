//
//  CoreDataTest.swift
//  RetsTalkTests
//
//  Created by KimMinSeok on 11/5/24.
//

import XCTest

final class CoreDataTest: XCTestCase {
    let coreDataRetrospectStorage = CoreDataRetrospectStorage()
    
    let testMessage = [Message(role: .assistant, content: "오늘 무엇을 하셨나요", createdAt: Date()),
                       Message(role: .user, content: "공부했어요", createdAt: Date()),
                       Message(role: .assistant, content: "잘하셨네요!", createdAt: Date())]
    
    lazy var testRetrosepct = [Retrospect(summary: "오늘 힘들었어요",
                                             isFinished: false,
                                             isBookmarked: false,
                                             createdAt: Date(),
                                             chat: []),
                               Retrospect(summary: "오늘 재밌었어요",
                                             isFinished: false,
                                             isBookmarked: false,
                                             createdAt: Date(),
                                             chat:testMessage)]
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
        try coreDataRetrospectStorage.removeAll()
    }
    
    func test_Save_회고가_CoreData에_저장되는지() throws {
        try coreDataRetrospectStorage.save(testRetrosepct[0])
        
        let coreDataRetrospect = try coreDataRetrospectStorage.fetchAll().first
        
        XCTAssertEqual(coreDataRetrospect?.summary, "오늘 힘들었어요")
    }
    
    func test_Save_여러가지_회고를_저장하는지() throws {
        try testRetrosepct.forEach { retrospect in
            try coreDataRetrospectStorage.save(retrospect)
        }
        
        let coreDataRetrospect = try coreDataRetrospectStorage.fetchAll()
        
        XCTAssertEqual(coreDataRetrospect.count, testRetrosepct.count)
    }
    
    func test_Save_회고가_메세지를_잘_가지고_있는지() throws {
        try coreDataRetrospectStorage.save(testRetrosepct[1])
        
        let coreDataRetrospect = try coreDataRetrospectStorage.fetchAll().first
        
        XCTAssertEqual(coreDataRetrospect?.chat.count, testRetrosepct[1].chat.count)
    }
    
    func test_회고의_채팅_순서가_알맞게_저장_되는지() throws {
        try coreDataRetrospectStorage.save(testRetrosepct[1])
        
        let coreDataRetrospect = try coreDataRetrospectStorage.fetchAll().first
        
        coreDataRetrospect?.chat.enumerated().forEach{ index, message in
            XCTAssertEqual(message.content, testMessage[index].content)
        }
    }
}
