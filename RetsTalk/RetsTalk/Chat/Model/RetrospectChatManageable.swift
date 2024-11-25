//
//  MessageManaga.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import Foundation
import Combine

protocol RetrospectChatManageable: Sendable {
    var retrospectSubject: CurrentValueSubject<Retrospect, Never> { get }
    var retrospectChatManagerListener: RetrospectChatManagerListener { get }
    
    func fetchMessages(offset: Int, amount: Int) async throws
    func send(_ message: Message) async throws
    func endRetrospect()
}
