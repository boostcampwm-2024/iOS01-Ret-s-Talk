//
//  NetworkRequestable.swift
//  RetsTalk
//
//  Created on 11/5/24.
//

import Foundation

protocol NetworkRequestable {
    func request(with urlRequestComposer: any URLRequestComposable) async throws -> (Data, URLResponse)
}
