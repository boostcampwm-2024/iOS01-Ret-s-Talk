//
//  URLRequestComposable.swift
//  RetsTalk
//
//  Created on 11/5/24.
//

protocol URLRequestComposable {
    associatedtype Path
    
    var scheme: String { get }
    var host: String { get }
    
    var path: Path { get set }
    var method: HTTPMethod { get set }
    var header: [String: String] { get set }
    var data: Encodable? { get set }
    var query: Encodable? { get set }
    
    func appendingPath(_ path: Path) -> Self
    func appendingMethod(_ path: HTTPMethod) -> Self
    func appendingHeader(_ path: [String: String]) -> Self
    func appendingData(_ path: Encodable) -> Self
    func appendingQuery(_ path: Encodable) -> Self
}
