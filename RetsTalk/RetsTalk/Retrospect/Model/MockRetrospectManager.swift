//
//  MockRetrospectManager.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

import Foundation

final class MockRetrospectManager: RetrospectManageable, RetrospectChatManagerListener {
    var retrospects: [Retrospect]
    let sharedUserID = UUID()
    
    private let retrospectStorage: Persistable
    private let assistantMessageProvider: AssistantMessageProvidable
    
    nonisolated init(
        retrospectStorage: Persistable,
        assistantMessageProvider: AssistantMessageProvidable
    ) {
        self.retrospectStorage = retrospectStorage
        self.assistantMessageProvider = assistantMessageProvider
        retrospects = []
    }
    
    func fetchRetrospects(offset: Int, amount: Int) async throws {
        let testableRetrospects = [
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
            Retrospect(userID: sharedUserID),
        ]
        sleep(1)
        retrospects.append(contentsOf: testableRetrospects)
    }
    
    func create() async throws -> any RetrospectChatManageable {
        let retrospect = Retrospect(userID: sharedUserID)
        retrospects.append(retrospect)
        
        let retrospectChatManager = RetrospectChatManager(
            retrospect: retrospect,
            messageStorage: UserDefaultsManager(),
            assistantMessageProvider: assistantMessageProvider,
            retrospectChatManagerListener: self
        )
        sleep(1)
        return retrospectChatManager
    }
    
    func update(_ retrospect: Retrospect) async throws {
        <#code#>
    }
    
    func delete(_ retrospect: Retrospect) async throws {
        sleep(1)
        retrospects.removeAll(where: { $0.id == retrospect.id })
    }
    
    // MARK: MessageManagerListener conformance
    
    func didUpdateRetrospect(_ retrospectChatManageable: any RetrospectChatManageable, retrospect: Retrospect) {
        <#code#>
    }
    
    func shouldTogglePin(_ retrospectChatManageable: any RetrospectChatManageable, retrospect: Retrospect) -> Bool {
        <#code#>
    }
}
