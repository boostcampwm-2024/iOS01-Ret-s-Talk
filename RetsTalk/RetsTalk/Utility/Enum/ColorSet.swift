//
//  ColorSet.swift
//  RetsTalk
//
//  Created by HanSeung on 11/13/24.
//

enum ColorSet {
    case blazingOrange
    case blueberry
    
    case background_main
    case background_retrospect
    case stroke_retrospect
    
    var hexCode: String {
        switch self {
        case .blazingOrange: return "FFA44A"
        case .blueberry: return "2C3E50"
        case .background_main: return "FAFAFA"
        case .background_retrospect: return "FFFFFF"
        case .stroke_retrospect: return "F1F1F1"
        }
    }
}
