//
//  Message.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/7/24.
//

import Foundation

struct Message: Hashable {
    let retrospectID: UUID
    let role: Role
    var content: String
    let createdAt: Date
    
    init(retrospectID: UUID, role: Role, content: String, createdAt: Date = Date()) {
        self.retrospectID = retrospectID
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }
    
    enum Role: String {
        case user
        case assistant
    }
}

// MARK: - EntityRepresentable

extension Message: EntityRepresentable {
    var mappingDictionary: [String: Any] {
        [
            "retrospectID": retrospectID,
            "isUser": role == .user,
            "content": content,
            "createdAt": createdAt,
        ]
    }
    
    init(dictionary: [String: Any]) {
        retrospectID = dictionary["retrospectID"] as? UUID ?? UUID()
        let isUser = dictionary["isUser"] as? Bool ?? true
        role = isUser ? .user : .assistant
        content = dictionary["content"] as? String ?? ""
        createdAt = dictionary["createdAt"] as? Date ?? Date()
    }
    
    static let entityName = "MessageEntity"
}
