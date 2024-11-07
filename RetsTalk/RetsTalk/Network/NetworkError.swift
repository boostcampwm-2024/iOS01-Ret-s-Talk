//
//  NetworkError.swift
//  RetsTalk
//
//  Created by HanSeung on 11/5/24.
//

enum NetworkError: Error {
    case invalidURL
    case badResponse
    case serverError(message: String)
    case unknown
    
    var description: String {
        switch self {
        case .invalidURL:
            "유효하지 않은 URL입니다."
        case .badResponse:
            "잘못된 응답입니다."
        case let .serverError(message):
            message
        case .unknown:
            "알 수 없는 오류입니다."
        }
    }
}
