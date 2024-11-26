//
//  MessageManagerListener.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

protocol RetrospectChatManagerListener: Actor {
    func didUpdateRetrospect(_ retrospectChatManageable: RetrospectChatManageable, retrospect: Retrospect)
    func shouldTogglePin(_ retrospectChatManageable: RetrospectChatManageable, retrospect: Retrospect) -> Bool
}
