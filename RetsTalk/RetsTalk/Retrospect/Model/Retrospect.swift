//
//  Retrospect.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/7/24.
//

import Foundation

struct Retrospect {
    let id: UUID = UUID()
    let author: User
    let summary: String? = nil
    var status: Status = .progress(.inputWaiting)
    let isPinned: Bool = false
    let createdAt: Date = Date()
    
    enum Status {
        case finish
        case progress(LastStatus)
    }
    
    enum LastStatus {
        case responseError
        case inputWaiting
        case responseWaiting
    }
}
