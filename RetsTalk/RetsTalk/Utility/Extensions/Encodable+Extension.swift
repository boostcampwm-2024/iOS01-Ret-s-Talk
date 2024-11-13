//
//  Encodable+Extension.swift
//  RetsTalk
//
//  Created by HanSeung on 11/5/24.
//

import Foundation

extension Encodable {
    /// 변수명과 값으로 딕셔너리를 만듭니다.
    /// - Returns: 딕셔너리.
    var dictionary: [String: Any] {
        get throws {
            guard let jsonObject = try? JSONSerialization.jsonObject(with: try encodeJSON()),
                  let dictionary = jsonObject as? [String: Any]
            else { throw CommonError.invalidData }
            
            return dictionary
        }
    }
    
    /// 변수명과 값으로 문자열 딕셔너리를 만듭니다.
    /// - Returns: 문자열 딕셔너리.
    var stringDictionary: [String: String] {
        get throws {
            var stringDictionary = [String: String]()
            (try dictionary).forEach { stringDictionary.updateValue("\($0.value)", forKey: $0.key) }
            return stringDictionary
        }
    }
    
    /// 데이터를 JSON으로 변환합니다.
    /// - Returns: JSON 데이터.
    func encodeJSON() throws -> Data {
        try JSONEncoder().encode(self)
    }
}

enum CommonError: Error {
    case invalidData
}
