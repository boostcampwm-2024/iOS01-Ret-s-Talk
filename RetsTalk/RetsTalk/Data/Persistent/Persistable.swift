//
//  Persistable.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/11/24.
//

import CoreData

protocol Persistable {
    func add<Entity: NSManagedObject>(entity: Entity) async throws -> Entity
    func update<Entity: NSManagedObject>(entity: Entity, updateHandler: (Entity) -> Void) throws -> Entity
    func fetch<Entity: NSManagedObject>(by request: NSFetchRequest<Entity>) -> [NSManagedObject]
    func delete<Entity: NSManagedObject>(entity: Entity) throws
    func delete<Entity: NSManagedObject>(by request: NSFetchRequest<Entity>) throws
}
