//
//  MockMessageManageable.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/20/24.
//

import Foundation

protocol MockMessageManageable {
    var retrospectID: UUID { get }
    var messages: [Message] { get }
    var messageManagerListener: MessageManagerListener { get }
    var messagePublisher: Published<[Message]>.Publisher { get }

    func fetchMessages(offset: Int, amount: Int)
    func send(_ message: Message) async throws
    func endRetrospect()
}
