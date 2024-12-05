//
//  RetrospectManageable.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import Combine

@RetrospectActor
protocol RetrospectManageable: Sendable {
    var retrospects: [Retrospect] { get }
    var retrospectsPublisher: AnyPublisher<SortedRetrospects, Never> { get }
    var errorPublisher: AnyPublisher<Swift.Error?, Never> { get }

    func createRetrospect() -> RetrospectChatManageable?
    func retrospectChatManager(of retrospect: Retrospect) -> RetrospectChatManageable?
    func retrospectCalendarManager() -> RetrospectCalendarManageable
    func fetchRetrospects(of kindList: [Retrospect.Kind])
    func fetchPreviousRetrospects() -> Int
    func fetchRetrospectsCount() -> (totalCount: Int, monthlyCount: Int)?
    func togglePinRetrospect(_ retrospect: Retrospect)
    func finishRetrospect(_ retrospect: Retrospect) async
    func deleteRetrospect(_ retrospect: Retrospect)
    func refreshRetrospectStorage(iCloudEnabled: Bool)
}
