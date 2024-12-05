//
//  RetrospectCalendarManager.swift
//  RetsTalk
//
//  Created by KimMinSeok on 12/5/24.
//

import Combine
import Foundation

final class RetrospectCalendarManager: RetrospectCalendarManageable {
    private let userID: UUID
    private var retrospectStorage: Persistable
    private let retrospectAssistantProvider: RetrospectAssistantProvidable
    
    private var retrospectsSubject: CurrentValueSubject<[Retrospect], Never>
    private(set) var errorSubject: PassthroughSubject<Swift.Error, Never>
    
    private(set) var retrospects: [Retrospect] {
        didSet {
            retrospectsSubject.send(retrospects)
        }
    }
    
    // MARK: Initialization
    
    init(
        userID: UUID,
        retrospectStorage: Persistable,
        retrospectAssistantProvider: RetrospectAssistantProvidable
    ) {
        self.userID = userID
        self.retrospectStorage = retrospectStorage
        self.retrospectAssistantProvider = retrospectAssistantProvider
        
        retrospectsSubject = CurrentValueSubject([])
        errorSubject = PassthroughSubject()
        retrospects = []
    }
    
    // MARK: RetrospectCalenarManageable conformance
    
    var retrospectsPublisher: AnyPublisher<[Retrospect], Never> {
        retrospectsSubject.eraseToAnyPublisher()
    }
    var errorPublisher: AnyPublisher<Swift.Error, Never> {
        errorSubject.eraseToAnyPublisher()
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
        return retrospectChatManager
    }
    
    func fetchRetrospects(of kindList: [Retrospect.Kind]) {
        do {
            for kind in kindList {
                let request = retrospectFetchRequest(for: kind)
                let fetchedRetrospects = try retrospectStorage.fetch(by: request)
                for retrospect in fetchedRetrospects where !retrospects.contains(retrospect) {
                    retrospects.append(retrospect)
                }
            }
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
        } catch {
            errorSubject.send(error)
        }
    }
    
    // MARK: Support retrospects fetching
    
    private func retrospectFetchRequest(for kind: Retrospect.Kind) -> PersistFetchRequest<Retrospect> {
        PersistFetchRequest<Retrospect>(
            predicate: kind.predicate(for: userID),
            sortDescriptors: [CustomSortDescriptor(key: "createdAt", ascending: false)],
            fetchLimit: kind.fetchLimit
        )
    }
    
    // MARK: Manage retrospects
    
    private var isPinAvailable: Bool {
        retrospects.filter({ $0.isPinned }).count < Numerics.pinLimit
    }
    
    private func updateRetrospects(by retrospect: Retrospect) {
        guard let matchingIndex = retrospects.firstIndex(where: { $0.id == retrospect.id }) else { return }
        
        retrospects[matchingIndex] = retrospect
    }
}

// MARK: - RetrospectChatManagerListener conformance

extension RetrospectCalendarManager: RetrospectChatManagerListener {
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

fileprivate extension RetrospectCalendarManager {
    enum Error: LocalizedError {
        case faildedFetch
        case invalidRetrospect
        
        var errorDescription: String? {
            switch self {
            case .faildedFetch:
                "회고를 불러올 수 없습니다."
            case .invalidRetrospect:
                "존재하지 않는 회고입니다."
            }
        }
        
        var failureReason: String? {
            switch self {
            case .faildedFetch:
                "회고를 불러올 수 없습니다."
            case .invalidRetrospect:
                "존재하지 않는 회고입니다."
            }
        }
    }
}

// MARK: - Constant

private extension RetrospectCalendarManager {
    enum Numerics {
        static let pinLimit = 2
    }
}
