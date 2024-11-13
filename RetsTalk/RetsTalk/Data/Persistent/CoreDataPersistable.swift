//
//  CoreDataPersistable.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/11/24.
//

import CoreData

protocol CoreDataPersistable {
    func add<Entity: NSManagedObject>(entityProvider: (NSManagedObjectContext) -> Entity) throws -> Entity
    func fetch<Entity: NSManagedObject>(by request: NSFetchRequest<Entity>) async throws -> [NSManagedObject]
    func update<Entity: NSManagedObject>(entity: Entity, updateHandler: (Entity) -> Void) throws -> Entity
    func delete<Entity: NSManagedObject>(entity: Entity) throws
    func delete<Entity: NSManagedObject>(by request: NSFetchRequest<Entity>) async throws
}
