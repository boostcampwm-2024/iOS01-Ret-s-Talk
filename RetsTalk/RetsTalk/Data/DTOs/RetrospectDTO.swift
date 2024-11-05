//
//  Retrospect.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/5/24.
//

import Foundation

struct RetrospectDTO {
    let summary: String?
    let isFinished: Bool
    let isBookmarked: Bool
    let createdAt: Date
    let chat: [MessageDTO]
}
