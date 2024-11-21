//
//  CLOVAStudioManager+AssistantMessageProvider.swift
//  RetsTalk
//
//  Created on 11/20/24.
//

import Foundation

extension CLOVAStudioManager: AssistantMessageProvidable {
    func requestAssistantMessage(for chat: [Message]) async throws -> Message {
        let assistantMessageComposer = CLOVAStudioAPI(path: .chatbot)
            .configureMethod(.post)
            .configureHeader(CLOVAStudioManager.assistantMessageHeader)
            .configureData(ChatParameter(chat: chat))
        let data = try await request(with: assistantMessageComposer)
        let assistantMessageDTO = try JSONDecoder().decode(AssistantMessageDTO.self, from: data)
        return assistantMessageDTO.message
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
        
        var message: Message {
            Message(role: .assistant, content: result?.message?.content ?? "", createdAt: Date())
        }
    }
    
    private struct MessageDTO: Codable {
        let role: String?
        let content: String?
        
        static let systemMessage = MessageDTO(
            role: "system",
            content: """
            너는 사용자의 회고를 도와주는 대화 상대야. 오늘 무슨 일이 있었는지, 아쉬운 점과 잘한 점 그리고 개선할 점을 위주로 대화를 이끌어가면 돼.
            사용자의 질문에 대답을 하기보다는, 사용자가 자신의 질문에 대해 스스로 답을 찾도록 유도해줘.
            """
        )
    }
}
