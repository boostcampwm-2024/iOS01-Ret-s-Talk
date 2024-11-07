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
