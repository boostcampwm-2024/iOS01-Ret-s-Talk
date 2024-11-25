//
//  CLOVAStudioManager.swift
//  RetsTalk
//
//  Created on 11/6/24.
//

import Foundation

actor CLOVAStudioManager: NetworkRequestable {
    let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func verifyStatus(from data: Data, and response: URLResponse) throws {
        guard let httpURLResponse = response as? HTTPURLResponse else { throw NetworkError.badResponse }
        
        let responseStatus = Status(statusCode: httpURLResponse.statusCode)
        switch responseStatus {
        case .success, .noContent:
            break
        default:
            let statusObject = try JSONDecoder().decode([String: StatusDTO].self, from: data)
            var errorMessage = responseStatus.description
            if let message = statusObject[StatusDTO.name]?.message {
                errorMessage += " \(message)"
            }
            throw NetworkError.serverError(message: errorMessage)
        }
    }
}

// MARK: - Status

fileprivate extension CLOVAStudioManager {
    enum Status: Int, CustomStringConvertible {
        case success = 200
        case noContent = 204
        
        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case notAcceptable = 406
        case requestTimeout = 408
        case mediaTypeError = 415
        case tooManyRequests = 429
        
        case internalServerError = 500
        case notYetImplemented = 501
        case gatewayTimeout = 504
        
        case unknown
        
        init(statusCode: Int) {
            self = Status(rawValue: statusCode) ?? .unknown
        }
        
        var description: String {
            switch self {
            case .success, .noContent:
                "성공."
            case .badRequest:
                "잘못된 요청입니다."
            case .unauthorized:
                "인증에 실패했습니다."
            case .forbidden:
                "수행할 수 없는 작업입니다."
            case .notFound:
                "요청한 자원을 찾을 수 없습니다."
            case .notAcceptable:
                "잘못된 미디어 형식입니다."
            case .requestTimeout:
                "요청 처리 시간이 초과되었습니다."
            case .mediaTypeError:
                "지원하지 않는 형식의 미디어 타입입니다."
            case .tooManyRequests:
                "너무 많은 요청이 수행되었습니다."
            case .internalServerError:
                "내부 서버에 오류가 발생했습니다."
            case .notYetImplemented:
                "구현되지 않은 API를 호출했습니다."
            case .gatewayTimeout:
                "게이트웨이 처리 시간을 초과했습니다."
            case .unknown:
                "알 수 없는 상태의 문제가 발생했습니다."
            }
        }
    }
    
    struct StatusDTO: Decodable {
        let code: String?
        let message: String?
        
        static let name = "status"
    }
}
