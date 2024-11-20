//
//  Message.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/7/24.
//

import Foundation

struct Message {
    let role: Role
    let content: String
    let createdAt: Date
    
    enum Role {
        case user
        case assistant
    }
}

// MARK: - EntityRepresentable

extension Message: EntityRepresentable {
    var mappingDictionary: [String: Any] {
        [
            "role": role,
            "content": content,
            "createdAt": createdAt,
        ]
    }
    
    init(dictionary: [String: Any]) {
        role = dictionary["role"] as? Role ?? .user
        content = dictionary["content"] as? String ?? ""
        createdAt = dictionary["createdAt"] as? Date ?? Date()
    }
    
    static let entityName = "MessageEntity"
}
