//
//  Retrospect.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/5/24.
//

import Foundation
import CoreData

struct RetrospectDTO: CoreDataConvertible {
    typealias Entity = RetrospectEntity
    
    let summary: String?
    let isFinished: Bool
    let isBookmarked: Bool
    let createdAt: Date
    let chat: [MessageDTO]
    
    func toEntity(context: NSManagedObjectContext) -> RetrospectEntity {
        let retrospect = RetrospectEntity(context: context)
        retrospect.summary = summary
        retrospect.isFinished = isFinished
        retrospect.isBookmarked = isBookmarked
        retrospect.createdAt = createdAt
        retrospect.chat = NSSet(array: chat.map {
            $0.toEntity(context: context)
        })
        
        return retrospect
    }
}
