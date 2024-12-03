//
//  CoreDataManager.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/13/24.
//

@preconcurrency import CoreData

final class CoreDataManager: Persistable, @unchecked Sendable {
    private let persistentContainer: NSPersistentCloudKitContainer
    private var lastHistoryDate: Date
    
    // MARK: Initialization
    
    init(
        inMemory: Bool = false,
        isiCloudSynced: Bool = false,
        name: String,
        completion: @escaping (Result<Void, Swift.Error>) -> Void
    ) {
        persistentContainer = NSPersistentCloudKitContainer(name: name)
        lastHistoryDate = Date()
        addObserver()
        
        do {
            try setUpPersistentContainer(inMemory: inMemory, isiCloudSynced: isiCloudSynced)
            persistentContainer.loadPersistentStores { [weak self] (_, error) in
                if error != nil {
                    completion(.failure(Error.storeSetUpFailed))
                } else {
                    try? self?.deleteOldPersistentHistory()
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func setUpPersistentContainer(inMemory: Bool, isiCloudSynced: Bool) throws {
        guard let description = persistentContainer.persistentStoreDescriptions.first
        else { throw Error.storeSetUpFailed }
        
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        if !isiCloudSynced {
            description.cloudKitContainerOptions = nil
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = false
        persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    // MARK: CloudKit observer

    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCloudKitEvent),
            name: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil
        )
    }
    
    @objc private func handleCloudKitEvent(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let event = userInfo[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                as? NSPersistentCloudKitContainer.Event else {
            return
        }
        
        switch event.type {
        case .import:
            if event.succeeded {
                print("Import Success")
                // notification을 받는 쪽에서 뷰를 업데이트 해주는 작업을 해줘야 하기 때문에 main 스레드에서 동작함을 보장해야함
                Task { @MainActor in
                    NotificationCenter.default.post(name: .coreDataImportedNotification, object: nil)
                }
            }
        default:
            print("Other CloudKit event occurred: \(event.type)")
        }
    }
    
    // MARK: Persistable conformance
    
    func add<Entity>(contentsOf entities: [Entity]) throws -> [Entity] where Entity: EntityRepresentable {
        guard entities.isNotEmpty else { return [] }
        
        let taskContext = newTaskContext()
        try taskContext.performAndWait { [weak self] in
            guard let batchInsertRequest = self?.batchInsertRequest(for: entities),
                  let batchInsertResult = try? taskContext.execute(batchInsertRequest) as? NSBatchInsertResult,
                  let success = batchInsertResult.result as? Bool, success
            else { throw Error.additionFailed }
        }
        try mergePersistentHistoryChanges()
        return entities
    }
    
    func fetch<Entity>(
        by request: any PersistFetchRequestable<Entity>
    ) throws -> [Entity] where Entity: EntityRepresentable {
        let taskContext = newTaskContext()
        let fetchedEntities = try taskContext.performAndWait { [weak self] in
            guard let fetchRequest = self?.fetchRequest(from: request),
                  let dictionaryList = try? taskContext.fetch(fetchRequest) as? [NSDictionary]
            else { throw Error.fetchingFailed }
            
            return dictionaryList.map { Entity(dictionary: $0 as? [String: Any] ?? [:]) }
        }
        return fetchedEntities
    }
    
    func fetchDataCount<Entity>(
        by request: any PersistFetchRequestable<Entity>
    ) throws -> Int where Entity: EntityRepresentable {
        let taskContext = newTaskContext()
        let fetchedCount = try taskContext.performAndWait { [weak self] in
            guard let fetchRequest = self?.fetchCountRequest(from: request),
                  let count = try? taskContext.count(for: fetchRequest)
            else { throw Error.fetchingFailed }
            
            return count
        }
        return fetchedCount
    }
    
    func update<Entity>(
        from sourceEntity: Entity,
        to updatingEntity: Entity
    ) throws -> Entity where Entity: EntityRepresentable {
        let taskContext = newTaskContext()
        try taskContext.performAndWait { [weak self] in
                guard let batchUpdateRequest = self?.batchUpdateRequest(from: sourceEntity, to: updatingEntity),
                      let batchUpdateResult = try? taskContext.execute(batchUpdateRequest) as? NSBatchUpdateResult,
                      let success = batchUpdateResult.result as? Bool, success
                else { throw Error.updateFailed }
        }
        try mergePersistentHistoryChanges()
        return updatingEntity
    }
    
    func delete<Entity>(contentsOf entities: [Entity]) throws where Entity: EntityRepresentable {
        let taskContext = newTaskContext()
        for entity in entities {
            try taskContext.performAndWait { [weak self] in
                guard let batchDeleteRequest = self?.batchDeleteRequest(for: entity),
                      let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult,
                      let success = batchDeleteResult.result as? Bool, success
                else { throw Error.deletionFailed }
            }
        }
        try mergePersistentHistoryChanges()
    }
    
    // MARK: Supporting methods
    
    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return taskContext
    }
    
    private func fetchRequest<Entity>(
        from request: any PersistFetchRequestable<Entity>
    ) -> NSFetchRequest<NSFetchRequestResult> where Entity: EntityRepresentable {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.entityName)
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.predicate = request.predicate?.nsPredicate
        fetchRequest.sortDescriptors = request.sortDescriptors.map { $0.nsSortDescriptor }
        fetchRequest.fetchLimit = request.fetchLimit
        fetchRequest.fetchOffset = request.fetchOffset
        return fetchRequest
    }
    
    private func fetchCountRequest<Entity>(
        from request: any PersistFetchRequestable<Entity>
    ) -> NSFetchRequest<NSNumber> where Entity: EntityRepresentable {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: Entity.entityName)
        fetchRequest.resultType = .countResultType
        return fetchRequest
    }
    
    private func entityPredicate<Entity>(
        _ entity: Entity
    ) -> NSPredicate where Entity: EntityRepresentable {
        let predicates = entity.mappingDictionary.map { (key, value) in
            NSPredicate(format: "\(key) == %@", argumentArray: [value])
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    // MARK: Batch request
    
    private func batchInsertRequest<Entity>(
        for entities: [Entity]
    ) -> NSBatchInsertRequest where Entity: EntityRepresentable {
        var index = 0
        let batchInsertRequest = NSBatchInsertRequest(entityName: Entity.entityName) { dictionary in
            guard index < entities.count else { return true }
            
            dictionary.addEntries(from: entities[index].mappingDictionary)
            index += 1
            return false
        }
        return batchInsertRequest
    }
    
    private func batchUpdateRequest<Entity>(
        from sourceEntity: Entity,
        to updatingEntity: Entity
    ) -> NSBatchUpdateRequest where Entity: EntityRepresentable {
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: Entity.entityName)
        batchUpdateRequest.predicate = entityPredicate(sourceEntity)
        batchUpdateRequest.propertiesToUpdate = updatingEntity.mappingDictionary
        return batchUpdateRequest
    }
    
    private func batchDeleteRequest<Entity>(
        for entity: Entity
    ) -> NSBatchDeleteRequest where Entity: EntityRepresentable {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.entityName)
        fetchRequest.predicate = entityPredicate(entity)
        return NSBatchDeleteRequest(fetchRequest: fetchRequest)
    }
    
    // MARK: Context merge
    
    private func mergePersistentHistoryChanges() throws {
        let viewContext = persistentContainer.viewContext
        let history = try fetchPersistentHistoryTransactionsAndChanges()
        viewContext.performAndWait {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
            }
        }
        lastHistoryDate = history.last?.timestamp ?? Date()
    }

    private func fetchPersistentHistoryTransactionsAndChanges() throws -> [NSPersistentHistoryTransaction] {
        let taskContext = newTaskContext()
        let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryDate)
        let historyChanges = try taskContext.performAndWait {
            let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
            guard let history = historyResult?.result as? [NSPersistentHistoryTransaction]
            else { throw Error.persistentHistoryChangeError }
            
            return history
        }
        return historyChanges
    }
    
    // MARK: Old history deletion
    
    private func deleteOldPersistentHistory() throws {
        let taskContext = newTaskContext()
        let deleteRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: Date().aMonthAgo())
        _ = try taskContext.performAndWait {
            try taskContext.execute(deleteRequest)
        }
    }
}

// MARK: - Error

extension CoreDataManager {
    enum Error: LocalizedError {
        case storeSetUpFailed
        
        case additionFailed
        case updateFailed
        case fetchingFailed
        case deletionFailed
        
        case persistentHistoryChangeError
        
        var errorDescription: String? {
            switch self {
            case .storeSetUpFailed:
                "저장소를 설정하는데 실패했습니다."
            case .persistentHistoryChangeError:
                "변경 기록을 처리하는데 오류가 발생했습니다."
            case .additionFailed:
                "데이터를 추가하는데 실패했습니다."
            case .updateFailed:
                "데이터를 최신화하는데 실패했습니다."
            case .fetchingFailed:
                "데이터를 불러오는데 실패했습니다."
            case .deletionFailed:
                "데이터를 삭제하는데 실패했습니다."
            }
        }
    }
}

// MARK: - Extends Date for readability

fileprivate extension Date {
    func aMonthAgo() -> Date {
        let secondsInOneMonth = TimeInterval(30 * 24 * 60 * 60)
        return self.addingTimeInterval(-secondsInOneMonth)
    }
}
