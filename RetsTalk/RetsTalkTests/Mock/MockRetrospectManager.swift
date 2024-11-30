//
//  RetrospectChatManagerListener.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/20/24.
//

final class MockRetrospectManager: RetrospectChatManagerListener {
    func didUpdateRetrospect(_ retrospectChatManageable: RetrospectChatManageable, retrospect: Retrospect) {}
    
    func shouldTogglePin(_ retrospectChatManageable: RetrospectChatManageable, retrospect: Retrospect) -> Bool {
        true
    }
}
