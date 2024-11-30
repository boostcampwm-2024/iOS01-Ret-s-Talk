//
//  RetrospectChatManagerListener.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

@RetrospectActor
protocol RetrospectChatManagerListener {
    func didUpdateRetrospect(_ retrospectChatManageable: RetrospectChatManageable, retrospect: Retrospect)
    func shouldTogglePin(_ retrospectChatManageable: RetrospectChatManageable, retrospect: Retrospect) -> Bool
}
