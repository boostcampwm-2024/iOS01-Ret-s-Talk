//
//  CoreDataManager.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/6/24.
//

enum CoreDataManager {
    @discardableResult
    static func addAndSave<T: CoreDataConvertible>(with object: T) throws -> T.Entity {
        let coreDataStorage = CoreDataStorage.shared
        let entity = object.toEntity(context: coreDataStorage.context)
        try coreDataStorage.saveContext()

        return entity
    }
}
