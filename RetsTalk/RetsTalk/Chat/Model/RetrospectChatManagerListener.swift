//
//  MessageManagerListener.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

protocol RetrospectChatManagerListener {
    func didFinishRetrospect(_ retrospectChatManageable: RetrospectChatManageable)
    func didChangeStatus(_ retrospectChatManageable: RetrospectChatManageable, to status: Retrospect.Status)
}
