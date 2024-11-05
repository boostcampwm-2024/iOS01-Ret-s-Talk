//
//  CoreDataTest.swift
//  RetsTalkTests
//
//  Created by KimMinSeok on 11/5/24.
//

import XCTest
import CoreData
@testable import RetsTalk

final class CoreDataTest: XCTestCase {

    var context: NSManagedObjectContext!
    
    let testMessage = [MessageDTO(isUser: true, content: "오늘 무엇을 하셨나요"),
                       MessageDTO(isUser: false, content: "공부했어요"),
                       MessageDTO(isUser: true, content: "잘하셨네요!")]
    
    override func setUpWithError() throws {
        context = CoreDataStorage.shared.context
    }

    override func tearDownWithError() throws {
        let fetchRequest = Message.fetchRequest()
        let items = try? context.fetch(fetchRequest)
            for item in items ?? [] {
                context.delete(item)
            }
            try? context.save()
    }
    
    func test_Save_기능이_정상적으로_동작하는지_확인() {
        let message = Message.addAndSave(with: testMessage[0])
        
        let coreDataMessage = try? context.fetch(Message.fetchRequest()).first
        
        XCTAssertEqual(coreDataMessage?.content, "오늘 무엇을 하셨나요")
    }
    
    func test_Save_여러가지_메세지를_저장하는지() {
        testMessage.forEach { messageDTO in
            Message.addAndSave(with: messageDTO)
        }
        let context = CoreDataStorage.shared.context
        
        let coreDataMessage = try? context.fetch(Message.fetchRequest())
        
        XCTAssertEqual(coreDataMessage?.count, testMessage.count)
    }

}
