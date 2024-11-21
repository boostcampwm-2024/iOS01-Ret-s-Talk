//
//  SummaryProviderTest.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/21/24.
//

import XCTest

final class SummaryProviderTest: XCTestCase {
    private var summaryProvider: SummaryProvider?
    private let chat = [
        Message(role: .assistant, content: "오늘 하루 동안 있었던 일들을 한번 되돌아볼까요? 어떤 일들이 있었는지 생각해 보세요.", createdAt: Date()),
        Message(role: .user, content: "오늘은 요약 기능을 개발했는데 CLOVAStudio를 사용했어", createdAt: Date()),
        Message(role: .assistant, content: "사용하기 편하셨나요??", createdAt: Date()),
        Message(role: .user, content: "앞에서 채팅 Manager가 구현되어 있어서 정말 편했어요", createdAt: Date()),
    ]

    override func setUp() {
        super.setUp()
        
        summaryProvider = CLOVAStudioManager(urlSession: .shared)
    }

    func test_대화_목록을_통해_요약을_적절하게_제공하는지() async throws {
        let summaryProvider = try XCTUnwrap(summaryProvider)
        
        do {
            let summary = try await summaryProvider.requestSummary(for: chat)
            print(summary)
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
