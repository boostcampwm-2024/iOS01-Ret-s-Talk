//
//  Message.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/7/24.
//

import Foundation

struct Message {
    var retrospectID: UUID
    let role: Role
    let content: String
    let createdAt: Date
    
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
        role = (dictionary["isUser"] as? Bool ?? true) ? .user : .assistant
        content = dictionary["content"] as? String ?? ""
        createdAt = dictionary["createdAt"] as? Date ?? Date()
    }
    
    static let entityName = "MessageEntity"
}
