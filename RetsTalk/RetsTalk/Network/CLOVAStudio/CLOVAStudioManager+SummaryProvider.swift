//
//  CLOVAStudioManager+SummaryProvider.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/21/24.
//

import Foundation

extension CLOVAStudioManager: SummaryProvider {
    func requestSummary(for chat: [Message]) async throws -> String {
        let summaryComposer = CLOVAStudioAPI(path: .chatbot)
            .configureMethod(.post)
            .configureHeader(CLOVAStudioManager.summaryHeader)
            .configureData(ChatSummaryParameter(chat: chat))
        let data = try await request(with: summaryComposer)
        let summaryDTO = try JSONDecoder().decode(SummaryDTO.self, from: data)
        return summaryDTO.summary
    }

    // MARK: Header

    private static let summaryHeader = [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-NCP-CLOVASTUDIO-API-KEY": CLOVAStudioSecret.CLOVA_STUDIO_API_KEY,
        "X-NCP-APIGW-API-KEY": CLOVAStudioSecret.APIGW_API_KEY,
        "X-NCP-CLOVASTUDIO-REQUEST-ID": CLOVAStudioSecret.CLOVA_STUDIO_CHAT_REQUEST_ID,
    ]

    // MARK: Summary parameter

    private struct ChatSummaryParameter: Encodable {
        var messages: [MessageDTO]

        init(chat: [Message]) {
            var messageParameters = [MessageDTO]()
            messageParameters.append(MessageDTO.summaryRequestMessage)
            var messageContents = chat.map({ $0.content })
            messageContents.removeLast()
            let messageContentsString = messageContents.joined(separator: "\n")
            messageParameters.append(MessageDTO(role: "user", content: messageContentsString))
            messages = messageParameters
        }
    }

    // MARK: Summary transper object

    private struct SummaryDTO: Decodable {
        let result: Result?

        struct Result: Decodable {
            let message: MessageDTO?
        }

        var summary: String {
            result?.message?.content ?? ""
        }
    }

    private struct MessageDTO: Codable {
        let role: String?
        let content: String?

        static let summaryRequestMessage = MessageDTO(
            role: "system",
            // swiftlint:disable line_length
            content: """
            당신은 주어진 텍스트를 단 한 줄로 간결하고 명확하게 요약하는 텍스트 요약 어시스턴트입니다.\n\t•\t핵심 정보를 추출하여 불필요한 부가 요소 없이 하나의 문장으로 요약합니다.\n\t•\t사용자의 대화 의도와 감정을 반영하며 자연스럽게 작성합니다.\n\t•\t대화가 짧거나 없으면 “보통의 하루를 보냄”으로 요약합니다.\n\t•\t결과에는 불필요한 접두어나 불필요한 부가 요소를 포함하지 않습니다.\n\t•\t단순히 텍스트를 요약하며, 추가적인 대화를 이어나가지 않습니다.\n아무런 입력이 없으면 \"보통의 하루를 보냄\"이라는 메시지를 줘\n\n목표\n\t•\t간결하고 명확한 한 줄 요약 생성.\n\t•\t대화를 확장하지 않고 요약만 수행.
            """
            // swiftlint:enable line_length
        )
    }
}
