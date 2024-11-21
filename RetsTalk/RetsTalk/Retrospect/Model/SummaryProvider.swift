//
//  summaryProvider.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/21/24.
//

protocol SummaryProvider {
    func requestSummary(for chat: [Message]) async throws -> String
}
