//
//  TestEntity.swift
//  RetsTalk
//
//  Created on 11/18/24.
//

struct TestEntity {
    let content: String
    let integer: Int
    
    init(content: String) {
        self.content = content
        integer = 0
    }
}

extension TestEntity: EntityRepresentable {
    var mappingDictionary: [String: Any] {
        [
            "content": content,
            "integer": integer,
        ]
    }
    
    init(dictionary: [String: Any]) {
        content = dictionary["content"] as? String ?? ""
        integer = dictionary["integer"] as? Int ?? 0
    }
    
    static let entityName = "Entity"
}
