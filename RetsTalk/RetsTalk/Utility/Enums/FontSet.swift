//
//  FontSet.swift
//  RetsTalk
//
//  Created by HanSeung on 11/13/24.
//

import UIKit

enum FontSet {
    /// bold
    case heavyTitle
    /// semiBold
    case title
    case semiTitle
    case body
    case caption
    
    var size: CGFloat {
        switch self {
        case .heavyTitle:
            return 34
        case .title:
            return 20
        case .semiTitle:
            return 16
        case .body:
            return 14
        case .caption:
            return 11
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .heavyTitle:
            return 41
        case .title:
            return 20
        case .semiTitle:
            return 20
        case .body:
            return 18
        case .caption:
            return 18
        }
    }
}
