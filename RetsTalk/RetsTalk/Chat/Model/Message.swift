//
//  Message.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/7/24.
//

import Foundation

struct Message {
    let retrospectID: UUID
    let role: Role
    var content: String
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
            "role": role,
            "content": content,
            "createdAt": createdAt,
        ]
    }
    
    init(dictionary: [String: Any]) {
        retrospectID = dictionary["retrospectID"] as? UUID ?? UUID()
        role = dictionary["role"] as? Role ?? .user
        content = dictionary["content"] as? String ?? ""
        createdAt = dictionary["createdAt"] as? Date ?? Date()
    }
    
    static let entityName = "MessageEntity"
}
