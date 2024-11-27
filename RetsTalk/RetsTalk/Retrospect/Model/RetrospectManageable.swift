//
//  RetrospectManageable.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

@RetrospectActor
protocol RetrospectManageable: Sendable {
    var retrospects: [Retrospect] { get }
    var newRetrospectsManager: RetrospectChatManageable? { get }
    var errorOccurred: Error? { get }
    
    func createRetrospect() async
    func fetchRetrospects(of kindSet: Set<Retrospect.Kind>) async
    func togglePinRetrospect(_ retrospect: Retrospect) async
    func finishRetrospect(_ retrospect: Retrospect) async
    func deleteRetrospect(_ retrospect: Retrospect) async
    
    func syncWithRetrospectStorage() async
}
