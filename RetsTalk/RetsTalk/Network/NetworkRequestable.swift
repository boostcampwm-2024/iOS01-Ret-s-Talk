//
//  NetworkRequestable.swift
//  RetsTalk
//
//  Created on 11/5/24.
//

import Foundation

protocol NetworkRequestable {
    var urlSession: URLSession { get }
    
    func request(with urlRequestComposer: any URLRequestComposable) async throws -> (Data, URLResponse)
}

extension NetworkRequestable {
    func request(with urlRequestComposer: any URLRequestComposable) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: try url(with: urlRequestComposer))
        request.httpMethod = urlRequestComposer.method.value
        request.httpBody = try urlRequestComposer.data?.encodeJSON()
        urlRequestComposer.header.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        let queryItems = try urlRequestComposer.query?.stringDictionary.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        request.url?.append(queryItems: queryItems ?? [])
        return try await urlSession.data(for: request)
    }
    
    private func url(with urlRequestComposer: any URLRequestComposable) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = urlRequestComposer.scheme
        urlComponents.host = urlRequestComposer.host
        urlComponents.path = urlRequestComposer.path.description
        
        guard let url = urlComponents.url else { throw NetworkError.invalidURL }
        
        return url
    }
}
