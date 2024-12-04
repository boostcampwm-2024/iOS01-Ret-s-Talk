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
    
    init(
        id: UUID = UUID(),
        userID: UUID,
        summary: String? = nil,
        status: Status = .inProgress(.waitingForUserInput),
        isPinned: Bool = false,
        createdAt: Date = Date(),
        chat: [Message] = []
    ) {
        self.id = id
        self.userID = userID
        self.summary = summary
        self.status = status
        self.isPinned = isPinned
        self.createdAt = createdAt
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

// MARK: - Hashable conformance

extension Retrospect: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Retrospect, rhs: Retrospect) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - EntityRepresentable conformance

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
    
    var identifyingDictionary: [String: Any] {
        ["id": id]
    }
    
    /// - Status
    /// status를 통해 Value를 가져오고 mapping
    /// - Chat
    /// Chat은 CoreData에 존재하지 않음
    /// 그래서 빈 배열로 만들고 Message.fetch로 들고오게 설정
    init(dictionary: [String: Any]) {
        id = dictionary["id"] as? UUID ?? UUID()
        userID = dictionary["userID"] as? UUID ?? UUID()
        summary = dictionary["summary"] as? String
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

// MARK: - Retrospect kind

extension Retrospect {
    enum Kind: Hashable {
        case pinned
        case inProgress
        case finished
        case previous(_ lastRetrospectCreatedDate: Date)
        case monthly(from: Date, to: Date)
        
        func predicate(for userID: UUID) -> CustomPredicate {
            switch self {
            case .pinned:
                CustomPredicate(format: "userID = %@ AND isPinned = %@", argumentArray: [userID, true])
            case .inProgress:
                CustomPredicate(
                    format: "userID = %@ AND status != %@",
                    argumentArray: [userID, Texts.retrospectFinished]
                )
            case .finished:
                CustomPredicate(
                    format: "userID = %@ AND status = %@ AND isPinned = %@",
                    argumentArray: [userID, Texts.retrospectFinished, false]
                )
            case .previous(let lastRetrospectCreatedDate):
                CustomPredicate(
                    format: "userID = %@ AND status = %@ AND isPinned = %@ AND createdAt < %@",
                    argumentArray: [userID, Texts.retrospectFinished, false, lastRetrospectCreatedDate]
                )
            case .monthly(let currentMonth, let nextMonth):
                CustomPredicate(
                    format: "userID == %@ AND createdAt >= %@ AND createdAt < %@",
                    argumentArray: [userID, currentMonth, nextMonth]
                )
            }
        }
        
        var fetchLimit: Int {
            switch self {
            case .pinned, .inProgress:
                2
            case .finished, .previous:
                30
            case .monthly:
                0
            }
        }
    }
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
