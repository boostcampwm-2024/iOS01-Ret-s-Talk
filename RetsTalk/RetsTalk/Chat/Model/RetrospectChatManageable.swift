//
//  MessageManaga.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

protocol RetrospectChatManageable: Actor {
    var retrospect: Retrospect { get }
    var errorOccurred: Error? { get }
    
    func sendMessage(_ text: String) async
    func resendLastMessage() async
    func fetchPreviousMessages() async
    func endRetrospect()
    func toggleRetrospectPin()
}
