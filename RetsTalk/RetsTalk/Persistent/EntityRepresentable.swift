//
//  EntityRepresentable.swift
//  RetsTalk
//
//  Created on 11/17/24.
//

protocol EntityRepresentable: Sendable {
    /// 현재의 데이터를 기반으로 변환한 딕셔너리 값.
    var dictionaryValue: [String: Any] { get }
    
    init(dictinary: [String: Any])
    
    static var entityName: String { get }
}
