//
//  MockRetrospectManager.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

import Foundation

final class MockRetrospectManager: RetrospectManageable, RetrospectChatManagerListener {
    var retrospects: [Retrospect] = []
    let sharedUserID = UUID()
    var errorOccurred: Swift.Error?
    
    nonisolated init() { }
    
    @discardableResult
    func createRetrospect() async -> (any RetrospectChatManageable)? {
        sleep(1)
        let newRetrospect = Retrospect(
            userID: sharedUserID,
            summary: "새로 추가한 아이",
            status: .finished,
            isPinned: false,
            createdAt: Date()
        )
        retrospects.append(newRetrospect)
        
        let retrospectChatManager = RetrospectChatManager(
            retrospect: newRetrospect,
            messageStorage: UserDefaultsManager(),
            assistantMessageProvider: CLOVAStudioManager(urlSession: URLSession.shared),
            retrospectChatManagerListener: self
        )
        errorOccurred = nil
        return retrospectChatManager
    }
    
    func fetchRetrospects(of kindSet: Set<Retrospect.Kind>) async {
        sleep(1)
        let testableRetrospects = [
            Retrospect(userID: sharedUserID,
                       summary: "해야할 일의 절반밖에 못했지만, 속도보다 방향이 더 중요하다는 걸 배운 날이었다.",
                       status: .finished,
                       isPinned: true,
                       createdAt: Date()),
            Retrospect(userID: sharedUserID,
                       summary: "회고의 중요성을 깨닫고, 혼자만이 아닌 함께 성장하기 위해 남은 시간 동안 성실히 임할 것을 다짐.",
                       status: .finished,
                       isPinned: true),
            Retrospect(userID: sharedUserID,
                       summary: "계획을 계속 수정했지만, 그 과정 속에서 나의 우선순위를 다시 생각해볼 수 있었다.",
                       status: .inProgress(.waitingForUserInput),
                       isPinned: false),
            Retrospect(userID: sharedUserID,
                       summary: "혼자서는 막막했던 문제도 함께 고민하니 쉽게 풀리며, 협업의 힘을 실감한 하루였다.",
                       status: .finished,
                       isPinned: false),
            Retrospect(userID: sharedUserID,
                       summary: "코드 리뷰를 통해 생각지도 못한 개선점을 알게 되었고, 내 자신을 돌아볼 수 있는 계기가 되었다.",
                       status: .finished,
                       isPinned: false),
        ]
        
        for retrospect in testableRetrospects {
            retrospects.append(retrospect)
        }
        
        errorOccurred = nil
    }
    
    func retrospectChatManager(of retrospect: Retrospect) -> (any RetrospectChatManageable)? {
        RetrospectChatManager(
            retrospect: retrospect,
            messageStorage: UserDefaultsManager(),
            assistantMessageProvider: CLOVAStudioManager(urlSession: URLSession.shared),
            retrospectChatManagerListener: self
        )
    }
    
    func togglePinRetrospect(_ retrospect: Retrospect) async {
        sleep(1)
        guard !retrospect.isPinned || isPinAvailable else { return }
        
        var updatingRetrospect = retrospect
        updatingRetrospect.isPinned.toggle()
        updateRetrospects(by: updatingRetrospect)
        errorOccurred = nil
    }
    
    func finishRetrospect(_ retrospect: Retrospect) async {
        sleep(1)
        var updatingRetrospect = retrospect
        updatingRetrospect.summary = "끝난 회고"
        updatingRetrospect.status = .finished
        updateRetrospects(by: updatingRetrospect)
        errorOccurred = nil
    }
    
    func deleteRetrospect(_ retrospect: Retrospect) async {
        sleep(1)
        retrospects.removeAll(where: { $0.id == retrospect.id })
        errorOccurred = nil
    }
    
    // MARK: RetrospectChatManagerListener conformance
    
    func didUpdateRetrospect(_ retrospectChatManageable: any RetrospectChatManageable, retrospect: Retrospect) {
        guard let matchingIndex = retrospects.firstIndex(where: { $0.id == retrospect.id })
        else { return }
        
        sleep(1)
        retrospects[matchingIndex] = retrospect
    }
    
    func shouldTogglePin(_ retrospectChatManageable: any RetrospectChatManageable, retrospect: Retrospect) -> Bool {
        isPinAvailable
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

// MARK: - Error

fileprivate extension MockRetrospectManager {
    enum Error: LocalizedError {
        case creationFailed
        case reachInProgressLimit
        case reachPinLimit
        
        var errorDescription: String? {
            switch self {
            case .creationFailed:
                "회고를 생성하는데 실패했습니다."
            case .reachInProgressLimit:
                "회고는 최대 2개까지 진행할 수 있습니다. 새로 생성하려면 기존의 회고를 끝내주세요."
            case .reachPinLimit:
                "회고는 최대 2개까지 고정할 수 있습니다. 다른 회고의 고정을 풀어주세요."
            }
        }
    }
}

// MARK: - Constant

fileprivate extension MockRetrospectManager {
    enum Numerics {
        static let pinLimit = 2
        static let inProgressLimit = 2
    }
}
