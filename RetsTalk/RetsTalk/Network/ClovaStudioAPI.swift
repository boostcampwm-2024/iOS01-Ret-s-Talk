//
//  ClovaStudioAPI.swift
//  RetsTalk
//
//  Created on 11/6/24.
//

struct ClovaStudioAPI: URLRequestComposable {
    static let scheme = "https"
    static let host = "clovastudio.stream.ntruss.com"
    
    var path: Path
    var method: HTTPMethod
    var header: [String: String]
    var data: Encodable?
    var query: Encodable?
    
    init(path: Path) {
        self.path = path
        method = .get
        header = [:]
    }
}

// MARK: - Path

extension ClovaStudioAPI {
    enum Path: CustomStringConvertible {
        case chatbot
        
        var description: String {
            switch self {
            case .chatbot:
                "/testapp/v1/chat-completions/HCX-DASH-001"
            }
        }
    }
}
