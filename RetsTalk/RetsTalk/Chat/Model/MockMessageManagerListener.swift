//
//  MockMessageManagerListener.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/19/24.
//

import Foundation

final class MockMessageManagerListener: MessageManagerListener {
    func didFinishRetrospect(_ messageManager: any MessageManageable) {

    }
    
    func didChangeStatus(_ messageManager: any MessageManageable, to status: Retrospect.Status) {
        
    }
}
