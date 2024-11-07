//
//  NetworkRequestable.swift
//  RetsTalk
//
//  Created on 11/5/24.
//

import Foundation

protocol NetworkRequestable {
    var urlSession: URLSession { get }
    
    func request(with urlRequestComposer: any URLRequestComposable) async throws -> Data
    func verifyStatus(from data: Data, and response: URLResponse) throws
}

// MARK: - Default implementation

extension NetworkRequestable {
    func request(with urlRequestComposer: any URLRequestComposable) async throws -> Data {
        var urlRequest = try urlRequest(with: urlRequestComposer)
        let (data, response) = try await urlSession.data(for: urlRequest)
        try verifyStatus(from: data, and: response)
        return data
    }
    
    private func urlRequest(with urlRequestComposer: any URLRequestComposable) throws -> URLRequest {
        let url = try url(with: urlRequestComposer)
        var request = URLRequest(url: url)
        request.httpMethod = urlRequestComposer.method.value
        urlRequestComposer.header.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        try urlRequestComposer.query?.stringDictionary.forEach {
            request.url?.append(queryItems: [URLQueryItem(name: $0.key, value: $0.value)])
        }
        request.httpBody = try urlRequestComposer.data?.encodeJSON()
        return request
    }
    
    private func url(with urlRequestComposer: any URLRequestComposable) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = type(of: urlRequestComposer).scheme
        urlComponents.host = type(of: urlRequestComposer).host
        urlComponents.path = urlRequestComposer.path.description
        guard let url = urlComponents.url else { throw NetworkError.invalidURL }
        
        return url
    }
}
