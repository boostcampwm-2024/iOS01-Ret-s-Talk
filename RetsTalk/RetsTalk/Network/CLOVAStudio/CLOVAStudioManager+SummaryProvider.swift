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
            messageParameters.append(contentsOf: chat.map({MessageDTO(role: $0.role.rawValue, content: $0.content)}))
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
            당신은 주어진 텍스트를 1줄로 간결하고 명확하게 요약하는 텍스트 요약 어시스턴트입니다.\n\t•\t텍스트에서 핵심 정보를 추출하여 하나의 문장으로 요약하세요.\n\t•\t사용자의 대화 의도와 감정을 반영하며, 자연스럽고 간결하게 작성하세요.\n\t•\t결과는 불필요한 부가 요소 없이 하나의 완전한 문장으로 작성해야 합니다.\n\t•\t대화가 짧거나 회고할 만한 것이 없는 경우에는 “보통의 하루를 보냄”이라고 요약하세요.\n\n\n예시 입력과 출력\n\t•\t입력\n“오늘 하루 동안 있었던 일들을 한번 되돌아볼까요? 어떤 일들이 있었는지 생각해 보세요.\n오늘은 팀 프로젝트 리팩토링 작업을 했어\n팀 프로젝트 리팩토링 작업을 하셨군요. 오늘 그 작업을 하면서 어떤 감정을 느끼셨나요?\n아쉬웠어\n리팩토링 작업이 아쉬우셨군요. 어떤 부분이 아쉬우셨나요?\n많은 걸 못한것 같아서 아쉬웠어\n그런 마음이 드실 수 있죠. 그래도 오늘 한 작업도 분명히 의미가 있을 거예요. 혹시 이 작업을 통해 배운 점이 있으신가요?\nNotificationCenter와 delegate의 차이점을 학습할 수 있었어”\n출력\n“팀 프로젝트 리팩토링 작업을 하며 NotificationCenter와 delegate의 차이점을 학습함”\n\t•\t입력\n“오늘은 별다른 일이 없었어. 그냥 평범한 하루였던 것 같아.”\n출력\n보통의 하루를 보냄\n\n\n목표\n\t•\t간결하고 명확한 한 줄 요약을 생성하는 것이 목표입니다.\n\t•\t회고할 만한 정보가 부족한 경우에도 간결한 요약을 제공할 수 있도록 보완하세요.
            """
            // swiftlint:enable line_length
        )
    }
}
