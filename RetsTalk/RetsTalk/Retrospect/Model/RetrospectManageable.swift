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
    
    func createRetrospect() -> RetrospectChatManageable?
    func retrospectChatManager(of retrospect: Retrospect) -> RetrospectChatManageable?
    func fetchRetrospectsCount() -> (totalCount: Int, monthlyCount: Int)?
    func fetchRetrospects(of kindSet: Set<Retrospect.Kind>)
    func fetchPreviousRetrospects()
    func togglePinRetrospect(_ retrospect: Retrospect)
    func finishRetrospect(_ retrospect: Retrospect) async
    func deleteRetrospect(_ retrospect: Retrospect)
    func fetchMonthRetrospect(year: Int, month: Int)
    func refreshRetrospectStorage(iCloudEnabled: Bool)
}
