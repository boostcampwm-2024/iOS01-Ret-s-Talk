//
//  MessageManagerListener.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

protocol MessageManagerListener {
    func didFinishRetrospect(_ messageManager: MessageManageable)
    func didChangeStatus(_ messageManager: MessageManageable, to status: Retrospect.Status)
}
