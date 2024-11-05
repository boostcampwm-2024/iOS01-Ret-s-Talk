//
//  HTTPMethod.swift
//  RetsTalk
//
//  Created on 11/5/24.
//

enum HTTPMethod: String {
    case delete
    case get
    case post
    case put
    case update
    
    var value: String {
        rawValue.uppercased()
    }
}
