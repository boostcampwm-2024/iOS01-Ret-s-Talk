//
//  EntityRepresentable.swift
//  RetsTalk
//
//  Created on 11/17/24.
//

protocol EntityRepresentable: Sendable {
    /// 현재의 데이터를 기반으로 변환한 딕셔너리 값.
    var mappingDictionary: [String: Any] { get }
    /// 현재의 데이터를 식별할 수 있도록 하는 딕셔너리 값.
    var identifyingDictionary: [String: Any] { get }
    
    init(dictionary: [String: Any])
    
    static var entityName: String { get }
}
