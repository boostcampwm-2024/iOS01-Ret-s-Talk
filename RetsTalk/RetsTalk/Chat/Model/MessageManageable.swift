//
//  MessageManaga.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import Foundation

protocol MessageManageable {
    var retrospectID: UUID { get }
    var messages: [Message] { get }
    var messageManagerListener: MessageManagerListener { get }
    
    func fetchMessages(offset: Int, amount: Int)
    func send(_ message: Message)
    func endRetrospect()
}
