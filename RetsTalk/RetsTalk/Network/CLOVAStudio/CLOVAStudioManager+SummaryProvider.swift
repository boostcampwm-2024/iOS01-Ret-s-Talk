//
//  CLOVAStudioManager+SummaryProvider.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/21/24.
//

import Foundation

extension CLOVAStudioManager: SummaryProvider {
    func requestSummary(for chat: [Message]) async throws -> String {
        let summaryComposer = CLOVAStudioAPI(path: .summary)
            .configureMethod(.post)
            .configureHeader(CLOVAStudioManager.summaryHeader)
            .configureData(ChatSummaryParameter(chat: chat))
        let data = try await request(with: summaryComposer)
        let summaryDTO = try JSONDecoder().decode(SummaryDTO.self, from: data)
        return summaryDTO.result.text
    }
    
    // MARK: - Header
    
    private static let summaryHeader = [
        "Content-Type": "application/json",
        "X-NCP-CLOVASTUDIO-API-KEY": CLOVAStudioSecret.CLOVA_STUDIO_API_KEY,
        "X-NCP-APIGW-API-KEY": CLOVAStudioSecret.APIGW_API_KEY,
        "X-NCP-CLOVASTUDIO-REQUEST-ID": CLOVAStudioSecret.CLOVA_STUDIO_SUMMARY_REQUEST_ID,
    ]
    
    // MARK: - 데이터 변환
    
    private struct ChatSummaryParameter: Encodable {
        let texts: [String]
        
        init(chat: [Message]) {
            let intro = "아래 대화들을 경험과 느낀점을 가지고 한문장으로 요약을 해줘 이 문장은 요약에 포함하면 절대 안돼"
            let chat = chat.map { $0.content }
            print([intro] + chat)
            self.texts = [intro] + chat
        }
    }
    
    private struct SummaryDTO: Decodable {
        let result: Result
        
        struct Result: Decodable {
            let text: String
        }
    }
}
