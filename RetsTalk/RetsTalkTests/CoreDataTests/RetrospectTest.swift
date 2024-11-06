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
    
    lazy var testRetrosepct = [RetrospectDTO(summary: "오늘 힘들었어요",
                                             isFinished: false,
                                             isBookmarked: false,
                                             createdAt: Date(),
                                             chat: []),
                               RetrospectDTO(summary: "오늘 재밌었어요",
                                             isFinished: false,
                                             isBookmarked: false,
                                             createdAt: Date(),
                                             chat:testMessage)]
    
    override func setUpWithError() throws {
        context = CoreDataStorage.shared.context
    }
    
    override func tearDownWithError() throws {
        let retrospectFetchRequest = RetrospectEntity.fetchRequest()
        let retrospectItems = try? context.fetch(retrospectFetchRequest)
        
        for item in retrospectItems ?? [] {
            context.delete(item)
        }
        
        try? context.save()
    }
    
    func test_Retrospect_Save_기능이_정상적으로_똥작하는지_확인() {
        XCTAssertNoThrow(try CoreDataManager.addAndSave(with: testRetrosepct[0]))
        
        let coreDataRetrospect = try? context.fetch(RetrospectEntity.fetchRequest()).first
        
        XCTAssertEqual(coreDataRetrospect?.summary, "오늘 힘들었어요")
    }
    
    func test_Retrospect_Save_여러가지_회고를_저장하는지() {
        XCTAssertNoThrow(try testRetrosepct.forEach {
            try CoreDataManager.addAndSave(with: $0)
        })
        
        let coreDataRetrospect = try? context.fetch(RetrospectEntity.fetchRequest())
        
        XCTAssertEqual(coreDataRetrospect?.count, testRetrosepct.count)
    }
    
    func test_Retrospect_Save_회고가_메세지를_잘_가지고_있는지() {
        XCTAssertNoThrow(try CoreDataManager.addAndSave(with: testRetrosepct[1]))
        
        let coreDataRetrospect = try? context.fetch(RetrospectEntity.fetchRequest()).first
        
        XCTAssertEqual(coreDataRetrospect?.chat?.count, testRetrosepct[1].chat.count)
    }
}
