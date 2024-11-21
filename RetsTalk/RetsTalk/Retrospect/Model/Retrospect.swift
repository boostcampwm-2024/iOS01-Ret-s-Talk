//
//  Retrospect.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/7/24.
//

import Foundation

struct Retrospect {
    let id: UUID
    let user: User
    var summary: String?
    var status: Status
    var isPinned: Bool
    let createdAt: Date
    private(set) var chat: [Message]
    
    init(user: User) {
        self.id = UUID()
        self.user = user
        self.status = .inProgress(.waitingForUserInput)
        self.isPinned = false
        self.createdAt = Date()
        self.chat = []
    }
    
    mutating func append(contentsOf messages: [Message]) {
        chat.append(contentsOf: messages)
    }
}

// MARK: Retrospect State

extension Retrospect {
    enum Status {
        case finished
        case inProgress(ProgressStatus)
    }
    
    enum ProgressStatus {
        case responseErrorOccurred
        case waitingForUserInput
        case waitingForResponse
    }
}
