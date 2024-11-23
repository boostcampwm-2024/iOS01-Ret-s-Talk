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
    
    init(dictionary: [String: Any]) {
        id = dictionary["id"] as? UUID ?? UUID()
        userID = dictionary["userID"] as? UUID ?? UUID()
        summary = dictionary["summary"] as? String ?? nil
        /// status를 통해 Value를 가져오고 mapping
        let statusValue = dictionary["status"] as? Int16 ?? 2
        status = Self.mapRawValueToStatus(statusValue)
        isPinned = dictionary["isPinned"] as? Bool ?? false
        createdAt = dictionary["createdAt"] as? Date ?? Date()
        /// Chat은 CoreData에 존재하지 않음
        /// 그래서 빈 배열로 만들고 Message.fetch로 들고오게 설정
        chat = []
    }
    
    private func mapStatusToRawValue(_ status: Status) -> Int16 {
        switch status {
        case .finished:
            return 0
        case .inProgress(let state):
            switch state {
            case .responseErrorOccurred:
                return 1
            case .waitingForUserInput:
                return 2
            case .waitingForResponse:
                return 3
            }
        }
    }
    
    private static func mapRawValueToStatus(_ rawValue: Int16) -> Status {
        switch rawValue {
        case 0:
            return .finished
        case 1:
            return .inProgress(.responseErrorOccurred)
        case 2:
            return .inProgress(.waitingForUserInput)
        case 3:
            return .inProgress(.waitingForResponse)
        default:
            return .inProgress(.waitingForUserInput)
        }
    }
    
    static let entityName = "MessageEntity"
}
