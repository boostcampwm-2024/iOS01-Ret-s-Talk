//
//  RetrospectManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Combine
import Foundation

typealias RetrospectAssistantProvidable = AssistantMessageProvidable & SummaryProvider

final class RetrospectManager: RetrospectManageable {
    private let userID: UUID
    private var retrospectStorage: Persistable
    private let retrospectAssistantProvider: RetrospectAssistantProvidable
    private(set) var retrospects: [Retrospect] {
        didSet {
            sortedRetrospectsSubject.send(RetrospectSortingHelper.execute(retrospects))
        }
    }
    
    private var sortedRetrospectsSubject: CurrentValueSubject<SortedRetrospects, Never> = .init(SortedRetrospects())
    private(set) var errorSubject: PassthroughSubject<Swift.Error?, Never> = .init()

    var retrospectsPublisher: AnyPublisher<SortedRetrospects, Never> {
        sortedRetrospectsSubject.eraseToAnyPublisher()
    }
    var errorPublisher: AnyPublisher<Swift.Error?, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    // MARK: Initialization
    
    nonisolated init(
        userID: UUID,
        retrospectStorage: Persistable,
        retrospectAssistantProvider: RetrospectAssistantProvidable
    ) {
        self.userID = userID
        self.retrospectStorage = retrospectStorage
        self.retrospectAssistantProvider = retrospectAssistantProvider
        
        retrospects = []
    }
    
    // MARK: RetrospectManageable conformance
    
    func createRetrospect() -> RetrospectChatManageable? {
        do {
            let newRetrospect = try createNewRetrospect()
            retrospects.append(newRetrospect)
            let retrospectChatManager = RetrospectChatManager(
                retrospect: newRetrospect,
                messageStorage: retrospectStorage,
                assistantMessageProvider: retrospectAssistantProvider,
                retrospectChatManagerListener: self
            )
            errorSubject.send(nil)
            return retrospectChatManager
        } catch {
            errorSubject.send(error)
            return nil
        }
    }
    
    func retrospectChatManager(of retrospect: Retrospect) -> (any RetrospectChatManageable)? {
        guard let retrospect = retrospects.first(where: { $0.id == retrospect.id })
        else {
            errorSubject.send(Error.invalidRetrospect)
            return nil
        }
        
        let retrospectChatManager = RetrospectChatManager(
            retrospect: retrospect,
            messageStorage: retrospectStorage,
            assistantMessageProvider: retrospectAssistantProvider,
            retrospectChatManagerListener: self
        )
        errorSubject.send(nil)
        return retrospectChatManager
    }
    
    func retrospectCalendarManager() -> RetrospectCalendarManageable {
        return RetrospectCalendarManager(
            userID: userID,
            retrospectStorage: retrospectStorage,
            retrospectAssistantProvider: retrospectAssistantProvider
        )
    }

    func fetchRetrospects(of kindList: [Retrospect.Kind]) {
        do {
            retrospects = []
            for kind in kindList {
                let request = retrospectFetchRequest(for: kind)
                let fetchedRetrospects = try retrospectStorage.fetch(by: request)
                for retrospect in fetchedRetrospects where !retrospects.contains(retrospect) {
                    retrospects.append(retrospect)
                }
            }
            errorSubject.send(nil)
        } catch {
            errorSubject.send(error)
        }
    }
    
    func fetchPreviousRetrospects() -> Int {
        do {
            let request = previousRetrospectFetchRequest(amount: Numerics.retrospectFetchAmount)
            let fetchedRetrospects = try retrospectStorage.fetch(by: request)
            retrospects.append(contentsOf: fetchedRetrospects)
            errorSubject.send(nil)
            return fetchedRetrospects.count
        } catch {
            errorSubject.send(error)
            return 0
        }
    }
    
    func fetchRetrospectsCount() -> (totalCount: Int, monthlyCount: Int)? {
        do {
            let totalFetchRequest = PersistFetchRequest<Retrospect>(fetchLimit: Numerics.fetchTotalDataCountLimit)
            let monthlyFetchRequest = monthlyRetrospectCountFetchRequest()
            
            let totalCount = try retrospectStorage.fetchDataCount(by: totalFetchRequest)
            let monthlyCount = try retrospectStorage.fetchDataCount(by: monthlyFetchRequest)
            
            errorSubject.send(nil)
            return (totalCount, monthlyCount)
        } catch {
            errorSubject.send(error)
            return nil
        }
    }
    
    func togglePinRetrospect(_ retrospect: Retrospect) {
        do {
            guard retrospect.isPinned || isPinAvailable else { throw Error.reachPinLimit }
            
            var updatingRetrospect = retrospect
            updatingRetrospect.isPinned.toggle()
            let updatedRetrospect = try retrospectStorage.update(from: retrospect, to: updatingRetrospect)
            updateRetrospects(by: updatedRetrospect)
            errorSubject.send(nil)
        } catch {
            errorSubject.send(error)
        }
    }
    
    func finishRetrospect(_ retrospect: Retrospect) async {
        do {
            var updatingRetrospect = retrospect
            if updatingRetrospect.status == .finished {
                updatingRetrospect.summary = try await retrospectAssistantProvider.requestSummary(for: retrospect.chat)
            }
            let updatedRetrospect = try retrospectStorage.update(from: retrospect, to: updatingRetrospect)
            updateRetrospects(by: updatedRetrospect)
            errorSubject.send(nil)
        } catch {
            errorSubject.send(error)
        }
    }
    
    func deleteRetrospect(_ retrospect: Retrospect) {
        do {
            try retrospectStorage.delete(contentsOf: [retrospect])
            retrospects.removeAll(where: { $0.id == retrospect.id })
            errorSubject.send(nil)
        } catch {
            errorSubject.send(error)
        }
    }

    func refreshRetrospectStorage(iCloudEnabled: Bool) {
        let newRetrospectStorage = CoreDataManager(
            isiCloudSynced: iCloudEnabled,
            name: Constants.Texts.coreDataContainerName
        ) { _ in }
        retrospectStorage = newRetrospectStorage
    }

    // MARK: Support retrospect creation
    
    private func createNewRetrospect() throws -> Retrospect {
        guard isCreationAvailable else { throw Error.reachInProgressLimit }
        
        let newRetrospect = Retrospect(userID: userID)
        guard let addedRetrospect = try retrospectStorage.add(contentsOf: [newRetrospect]).first
        else { throw Error.creationFailed }
        
        return addedRetrospect
    }
    
    // MARK: Support retrospect fetching
    
    private func retrospectFetchRequest(for kind: Retrospect.Kind) -> PersistFetchRequest<Retrospect> {
        PersistFetchRequest<Retrospect>(
            predicate: kind.predicate(for: userID),
            sortDescriptors: [CustomSortDescriptor(key: "createdAt", ascending: false)],
            fetchLimit: kind.fetchLimit
        )
    }
    
    private func previousRetrospectFetchRequest(amount: Int) -> PersistFetchRequest<Retrospect> {
        let recentDateSorting = CustomSortDescriptor(key: Texts.retrospectSortKey, ascending: false)
        let finishedRetrospects = sortedRetrospectsSubject.value[2]
        let lastRetrospectCreatedDate = finishedRetrospects.last?.createdAt ?? Date()
        let predicate = Retrospect.Kind.predicate(.previous(lastRetrospectCreatedDate))(for: userID)
        return PersistFetchRequest<Retrospect>(
            predicate: predicate,
            sortDescriptors: [recentDateSorting],
            fetchLimit: Retrospect.Kind.previous(lastRetrospectCreatedDate).fetchLimit
        )
    }
    
    private func monthlyRetrospectCountFetchRequest() -> PersistFetchRequest<Retrospect> {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())),
              let nextMonth = calendar.date(byAdding: DateComponents(month: 1), to: currentMonth)
        else {
            return PersistFetchRequest<Retrospect>(fetchLimit: 0)
        }
        
        let predicate = Retrospect.Kind.predicate(.monthly(fromDate: currentMonth, toDate: nextMonth))(for: userID)
        return PersistFetchRequest(
            predicate: predicate,
            fetchLimit: Retrospect.Kind.monthly(fromDate: currentMonth, toDate: nextMonth).fetchLimit
        )
    }
    
    // MARK: Manage retrospects
    
    private var isCreationAvailable: Bool {
        retrospects.filter({ $0.status != .finished }).count < Numerics.inProgressLimit
    }
    
    private var isPinAvailable: Bool {
        retrospects.filter({ $0.isPinned }).count < Numerics.pinLimit
    }
    
    private func updateRetrospects(by retrospect: Retrospect) {
        guard let matchingIndex = retrospects.firstIndex(where: { $0.id == retrospect.id }) else { return }
        
        retrospects[matchingIndex] = retrospect
    }
}

// MARK: - RetrospectChatManagerListener conformance

extension RetrospectManager: RetrospectChatManagerListener {
    func didUpdateRetrospect(_ retrospectChatManageable: RetrospectChatManageable, retrospect: Retrospect) throws {
        guard let matchingIndex = retrospects.firstIndex(where: { $0.id == retrospect.id })
        else { return }
        
        if !retrospects[matchingIndex].isEqualInStorage(retrospect) {
            Task {
                let updatedRetrospect = try retrospectStorage.update(from: retrospects[matchingIndex], to: retrospect)
                switch updatedRetrospect.status {
                case .finished:
                    await finishRetrospect(updatedRetrospect)
                default:
                    break
                }
            }
        }
        retrospects[matchingIndex] = retrospect
    }
    
    func shouldTogglePin(_ retrospectChatManageable: RetrospectChatManageable, retrospect: Retrospect) -> Bool {
        retrospect.isPinned || isPinAvailable
    }
}

// MARK: - Error

fileprivate extension RetrospectManager {
    enum Error: LocalizedError {
        case creationFailed
        case reachInProgressLimit
        case reachPinLimit
        case invalidRetrospect
        
        var errorDescription: String? {
            switch self {
            case .creationFailed:
                "회고를 생성할 수 없습니다."
            case .reachInProgressLimit:
                "회고 생성 제한"
            case .reachPinLimit:
                "회고 고정 제한"
            case .invalidRetrospect:
                "존재하지 않는 회고입니다."
            }
        }
        
        var failureReason: String? {
            switch self {
            case .creationFailed:
                "회고 생성에 실패했습니다."
            case .reachInProgressLimit:
                "최대 2개의 회고만 진행할 수 있습니다.\n새로 생성하려면 기존 회고를 종료해주세요."
            case .reachPinLimit:
                "최대 2개의 회고만 고정할 수 있습니다.\n다른 회고의 고정을 해제해주세요."
            case .invalidRetrospect:
                "존재하지 않는 회고입니다."
            }
        }
    }
}

// MARK: - Constant

fileprivate extension RetrospectManager {
    enum Numerics {
        static let fetchTotalDataCountLimit = 0
        static let pinLimit = 2
        static let inProgressLimit = 2
        static let retrospectFetchAmount = 2
    }
    
    enum Texts {
        static let retrospectFinished = "retrospectFinished"
        static let retrospectSortKey = "createdAt"
    }
}
