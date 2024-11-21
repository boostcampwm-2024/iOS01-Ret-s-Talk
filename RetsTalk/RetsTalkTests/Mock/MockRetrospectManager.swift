//
//  MockMessageManagerListener.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/20/24.
//

final class MockRetrospectManager: MessageManagerListener {
    func didFinishRetrospect(_ messageManager: any MessageManageable) {}
    
    func didChangeStatus(_ messageManager: any MessageManageable, to status: Retrospect.Status) {}
}
