//
//  MockMessageManagerListener.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/20/24.
//

final class MockRetrospectManager: RetrospectChatManagerListener {
    func didFinishRetrospect(_ messageManager: RetrospectChatManageable) {}
    
    func didChangeStatus(_ messageManager: RetrospectChatManageable, to status: Retrospect.Status) {}
}
