//
//  RetrospectManageable.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

@RetrospectActor
protocol RetrospectManageable: Sendable {
    var retrospects: [Retrospect] { get }
    var errorOccurred: Error? { get }
    
    func createRetrospect() async -> RetrospectChatManageable?
    func retrospectChatManager(of retrospect: Retrospect) -> RetrospectChatManageable?
    func fetchRetrospects(of kindSet: Set<Retrospect.Kind>) async
    func fetchPreviousRetrospects() async
    func fetchRetrospectsCount() async -> Int?
    func togglePinRetrospect(_ retrospect: Retrospect) async
    func finishRetrospect(_ retrospect: Retrospect) async
    func deleteRetrospect(_ retrospect: Retrospect) async
    func replaceRetrospectStorage(_ newRetrospectStorage: Persistable)
    func fetchMonthRetrospect(year: Int, month: Int)
}
