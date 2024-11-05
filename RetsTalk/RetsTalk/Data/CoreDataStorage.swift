//
//  CoreDataStorage.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/5/24.
//

import CoreData

final class CoreDataStorage {
    
    static let shared = CoreDataStorage()
    
    var context : NSManagedObjectContext { persistentContainer.viewContext }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RetsTalk")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private init() { }
    
    // MARK: - Core Data Saving support
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
}

