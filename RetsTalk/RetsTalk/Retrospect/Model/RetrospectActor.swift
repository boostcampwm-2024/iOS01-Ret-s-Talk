//
//  RetrospectActor.swift
//  RetsTalk
//
//  Created on 11/26/24.
//

@globalActor
final actor RetrospectActor {
    static let shared = RetrospectActor()
    
    private init() {}
    
    static func run<T>(
        resultType: T.Type = T.self,
        body: @RetrospectActor () throws -> T
    ) async rethrows -> T where T: Sendable {
        try await body()
    }
}
