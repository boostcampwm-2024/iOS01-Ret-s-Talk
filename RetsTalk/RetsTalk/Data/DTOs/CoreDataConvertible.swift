//
//  CoreDataConvertible.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/6/24.
//

import CoreData

protocol CoreDataConvertible {
    associatedtype Entity: NSManagedObject

    func toEntity(context: NSManagedObjectContext) -> Entity
}
