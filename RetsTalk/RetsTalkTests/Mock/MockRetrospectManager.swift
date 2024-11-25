//
//  MockMessageManagerListener.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/20/24.
//

final class MockRetrospectManager: RetrospectChatManagerListener {
    func didFinishRetrospect(_ retrospectChatManager: any RetrospectChatManageable) {}
    
    func didChangeStatus(_ retrospectChatManager: any RetrospectChatManageable, to status: Retrospect.Status) {}
}
