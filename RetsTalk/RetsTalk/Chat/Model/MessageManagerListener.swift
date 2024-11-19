//
//  MessageManagerListener.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

protocol MessageManagerListener {
    func didFinishRetrospect(_ messageManager: MessageManager)
    func didChangStatus(_ messageManager: MessageManager, to status: Retrospect.Status)
}
