//
//  Retrospect.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/7/24.
//

import Foundation

struct Retrospect {
    let id: UUID
    let userID: UUID
    var summary: String?
    var status: Status
    var isPinned: Bool
    let createdAt: Date
    private(set) var chat: [Message]
    
    init(userID: UUID, chat: [Message] = []) {
        self.id = UUID()
        self.userID = userID
        self.status = .inProgress(.waitingForUserInput)
        self.isPinned = false
        self.createdAt = Date()
        self.chat = chat
    }
    
    mutating func prepend(contentsOf messages: [Message]) {
        chat.insert(contentsOf: messages, at: chat.startIndex)
    }
    
    mutating func append(contentsOf messages: [Message]) {
        chat.append(contentsOf: messages)
    }
}

// MARK: - Retrospect State

extension Retrospect {
    enum Status: Equatable {
        case finished
        case inProgress(ProgressState)
    }
    
    enum ProgressState {
        case responseErrorOccurred
        case waitingForUserInput
        case waitingForResponse
    }
}

// MARK: - EntityRepresentable

extension Retrospect: EntityRepresentable {
    var mappingDictionary: [String: Any] {
        [
            "id": id,
            "userID": userID,
            "summary": summary ?? "",
            "status": mapStatusToRawValue(status),
            "isPinned": isPinned,
            "createdAt": createdAt,
            "chat": chat,
        ]
    }
    
    /// - Status
    /// status를 통해 Value를 가져오고 mapping
    /// - Chat
    /// Chat은 CoreData에 존재하지 않음
    /// 그래서 빈 배열로 만들고 Message.fetch로 들고오게 설정
    init(dictionary: [String: Any]) {
        id = dictionary["id"] as? UUID ?? UUID()
        userID = dictionary["userID"] as? UUID ?? UUID()
        summary = dictionary["summary"] as? String ?? nil
        
        let statusValue = dictionary["status"] as? Int16 ?? 2
        status = Self.mapRawValueToStatus(statusValue)
        isPinned = dictionary["isPinned"] as? Bool ?? false
        createdAt = dictionary["createdAt"] as? Date ?? Date()
        
        chat = []
    }
    
    private func mapStatusToRawValue(_ status: Status) -> Int16 {
        switch status {
        case .finished:
            0
        case .inProgress(let state):
            switch state {
            case .responseErrorOccurred:
                1
            case .waitingForUserInput:
                2
            case .waitingForResponse:
                3
            }
        }
    }
    
    private static func mapRawValueToStatus(_ rawValue: Int16) -> Status {
        switch rawValue {
        case 0:
            .finished
        case 1:
            .inProgress(.responseErrorOccurred)
        case 2:
            .inProgress(.waitingForUserInput)
        case 3:
            .inProgress(.waitingForResponse)
        default:
            .inProgress(.waitingForUserInput)
        }
    }
    
    static let entityName = "MessageEntity"
}
