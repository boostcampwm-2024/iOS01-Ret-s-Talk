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
        let statusValue = dictionary["status"] as? String ?? Texts.waitingForUserInput
        status = Self.mapRawValueToStatus(statusValue)
        isPinned = dictionary["isPinned"] as? Bool ?? false
        createdAt = dictionary["createdAt"] as? Date ?? Date()
        chat = []
    }
    
    private func mapStatusToRawValue(_ status: Status) -> String {
        switch status {
        case .finished:
            Texts.retrospectFinished
        case .inProgress(let state):
            switch state {
            case .responseErrorOccurred:
                Texts.responseErrorOccurred
            case .waitingForUserInput:
                Texts.waitingForUserInput
            case .waitingForResponse:
                Texts.waitingForResponse
            }
        }
    }
    
    private static func mapRawValueToStatus(_ rawValue: String) -> Status {
        switch rawValue {
        case Texts.retrospectFinished:
            .finished
        case Texts.responseErrorOccurred:
            .inProgress(.responseErrorOccurred)
        case Texts.waitingForUserInput:
            .inProgress(.waitingForUserInput)
        case Texts.waitingForResponse:
            .inProgress(.waitingForResponse)
        default:
            .inProgress(.waitingForUserInput)
        }
    }
    
    static let entityName = "RetrospectEntity"
}

// MARK: - Constants

private extension Retrospect {
    enum Texts {
        static let retrospectFinished = "retrospectFinished"
        static let responseErrorOccurred = "responseErrorOccurred"
        static let waitingForUserInput = "waitingForUserInput"
        static let waitingForResponse = "waitingForResponse"
    }
}
