//
//  MockMessageManager.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/19/24.
//

import Foundation

final class MockMessageManager: MessageManageable {
    var retrospectID: UUID
    
    var messages: [Message]
    
    var messageManagerListener: any MessageManagerListener

    init(messageManagerListener: any MessageManagerListener) {
        retrospectID = UUID()
        messages = []
        self.messageManagerListener = messageManagerListener
    }

    func fetchMessages(offset: Int, amount: Int) -> [Message] {
        let dummies = [
            Message(role: .assistant, content: "오늘 하루는 어떠셨나요?", createdAt: Date()),
            Message(role: .user, content: "오늘 팀원을 만났어요", createdAt: Date()),
            Message(role: .assistant, content: "팀원을 만나서 무엇을 하셨나요?", createdAt: Date()),
            Message(role: .user, content: "어떤 쪽으로 개발을 할까 대화를 많이 나눴습니다. 근데 마음이 조금 급해지고 좋은 대화를 많이 나눈 것 같지 않아서 걱정입니다.", createdAt: Date()),
            Message(role: .assistant, content: "저런 걱정이 이만저만 아니시겠군요? 저는 글자 수를 채우기 위해서 열심히 늘리고 있답니다. 왜냐면 긴 글도 테스트를 할 수 있어야 하기 때문이죠. 그럼 한마디만 더 하고 대화를 부탁드립니다?", createdAt: Date()),
        ]
        if dummies.count < offset+amount {
            return dummies
        }
        let returnValue = Array(dummies[offset..<offset+amount])
        return returnValue
    }
    @MainActor
    func send(_ message: Message) async throws -> Message {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return Message(role: .assistant, content: "이것은 응답값 입니다.", createdAt: Date())
    }
    
    func endRetrospect() {

    }
}
