//
//  AssistantMessageProviderTest.swift
//  NetworkTests
//
//  Created by Byeongjo Koo on 11/20/24.
//

import XCTest

final class AssistantMessageProviderTest: XCTestCase {
    private var assistantMessageProvider: AssistantMessageProvidable?

    override func setUp() {
        super.setUp()
        
        assistantMessageProvider = CLOVAStudioManager(urlSession: .shared)
    }

    func test_대화_목록을_바탕으로_도움_메시지를_받아오는지() async throws {
        let assistantMessageProvider = try XCTUnwrap(assistantMessageProvider)
        let chat = [Message(retrospectID: UUID(), role: .user, content: "", createdAt: Date())]
        
        do {
            let message = try await assistantMessageProvider.requestAssistantMessage(for: chat)
            print(message)
        } catch {
            if let error = error as? LocalizedError,
               let description = error.errorDescription {
                XCTFail(description)
            } else {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
