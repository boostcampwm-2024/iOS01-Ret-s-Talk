//
//  URLRequestComposable.swift
//  RetsTalk
//
//  Created on 11/5/24.
//

import Foundation

protocol URLRequestComposable {
    associatedtype Path: CustomStringConvertible
    
    var scheme: String { get }
    var host: String { get }
    
    var path: Path { get set }
    var method: HTTPMethod { get set }
    var header: [String: String] { get set }
    var data: Encodable? { get set }
    var query: Encodable? { get set }
    
    func configurePath(_ path: Path) -> Self
    func configureMethod(_ method: HTTPMethod) -> Self
    func configureHeader(_ header: [String: String]) -> Self
    func configureData(_ data: Encodable) -> Self
    func configureQuery(_ query: Encodable) -> Self
}

extension URLRequestComposable {
    private func configure(_ configure: (inout Self) -> Void) -> Self {
        var copy = self
        configure(&copy)
        return copy
    }
    
    func configurePath(_ path: Path) -> Self {
        configure { $0.path = path }
    }
    
    func configureMethod(_ method: HTTPMethod) -> Self {
        configure { $0.method = method }
    }
    
    func configureHeader(_ header: [String: String]) -> Self {
        configure { $0.header = header }
    }
    
    func configureData(_ data: Encodable) -> Self {
        configure { $0.data = data }
    }
    
    func configureQuery(_ query: Encodable) -> Self {
        configure { $0.query = query }
    }
}
