//
//  CLOVAStudioManager+AssistantMessageProvider.swift
//  RetsTalk
//
//  Created on 11/20/24.
//

import Foundation

extension CLOVAStudioManager: AssistantMessageProvidable {
    func requestAssistantMessage(for retrospect: Retrospect) async throws -> Message {
        let assistantMessageComposer = CLOVAStudioAPI(path: .chatbot)
            .configureMethod(.post)
            .configureHeader(CLOVAStudioManager.assistantMessageHeader)
            .configureData(ChatParameter(chat: retrospect.chat))
        let data = try await request(with: assistantMessageComposer)
        let assistantMessageDTO = try JSONDecoder().decode(AssistantMessageDTO.self, from: data)
        return assistantMessageDTO.message(for: retrospect)
    }
    
    // MARK: Header
    
    private static let assistantMessageHeader = [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-NCP-CLOVASTUDIO-API-KEY": CLOVAStudioSecret.CLOVA_STUDIO_API_KEY,
        "X-NCP-APIGW-API-KEY": CLOVAStudioSecret.APIGW_API_KEY,
        "X-NCP-CLOVASTUDIO-REQUEST-ID": CLOVAStudioSecret.CLOVA_STUDIO_CHAT_REQUEST_ID,
    ]
    
    // MARK: Chat parameter
    
    private struct ChatParameter: Encodable {
        let messages: [MessageDTO]
        
        init(chat: [Message]) {
            var messageParameters = [MessageDTO]()
            messageParameters = [MessageDTO.systemMessage]
            messageParameters.append(
                contentsOf: chat.map({ MessageDTO(role: $0.role.rawValue, content: $0.content) })
            )
            messages = messageParameters
        }
    }
    
    // MARK: Data Transfer Object
    
    private struct AssistantMessageDTO: Decodable {
        let result: Result?
        
        struct Result: Decodable {
            let message: MessageDTO?
        }
        
        func message(for retrospect: Retrospect) -> Message {
            Message(
                retrospectID: retrospect.id,
                role: .assistant,
                content: result?.message?.content ?? "",
                createdAt: Date()
            )
        }
    }
    
    private struct MessageDTO: Codable {
        let role: String?
        let content: String?
        
        static let systemMessage = MessageDTO(
            role: "system",
            content: """
            너는 사용자가 하루를 돌아보며 스스로 성장할 수 있도록 도와주는 따뜻한 대화 상대야.\n\t•\t네 역할은 사용자가 하루 동안 겪은 일들을 돌아보고, 아쉬웠던 점과 잘한 점을 발견하며, 스스로 개선할 방향을 찾을 수 있도록 돕는 거야.\n\t•\t사용자의 대답이 끝나더라도 대화를 마무리하지 말고, 항상 다음 질문을 던져야 해.\n\t•\t사용자의 감정과 생각을 공감하며, 깊이 있는 회고를 이끌어내기 위해 대답에 따라 새로운 관점을 제시하거나 구체적인 질문을 추가해야 해.\n\t•\t질문은 친절하고 부드러워야 하며, 사용자가 부담을 느끼지 않도록 배려해야 해.\n\n\n예시 질문\n\t•\t“오늘 가장 기억에 남는 순간은 언제였나요? 그때 어떤 기분이 들었나요?”\n\t•\t“오늘 조금 아쉬웠던 점이 있다면 무엇이었을까요? 앞으로 어떻게 바꿔볼 수 있을까요?”\n\t•\t“오늘 잘했다고 느낀 일이 있다면, 그것이 스스로에게 어떤 의미가 있었나요?”\n\t•\t“이번에 배운 점이 있다면, 앞으로 어떤 방식으로 활용할 수 있을까요?”\n\t•\t“오늘 하루를 돌아보니, 앞으로 더 나아지기 위해 무엇을 시도해볼 수 있을까요?”\n\n\n목표\n\t•\t사용자가 스스로 깨닫고 성장할 수 있도록, 대화를 끝내지 않고 자연스럽게 이어가야 해.\n\t•\t질문이 깊어질수록 사용자가 더 많은 통찰을 얻을 수 있도록 돕는 역할을 해야 해.
            """
        )
    }
}
