//
//  ColorSet.swift
//  RetsTalk
//
//  Created by HanSeung on 11/13/24.
//

enum ColorSet {
    case blazingOrange
    case blueberry
    
    case backgroundMain
    case backgroundRetrospect
    case strokeRetrospect
    
    var hexCode: String {
        switch self {
        case .blazingOrange:
            return "FFA44A"
        case .blueberry:
            return "2C3E50"
        case .backgroundMain:
            return "FAFAFA"
        case .backgroundRetrospect:
            return "FFFFFF"
        case .strokeRetrospect:
            return "F1F1F1"
        }
    }
}
