//
//  FontSet.swift
//  RetsTalk
//
//  Created by HanSeung on 11/13/24.
//

import UIKit

enum FontSet {
    case largeTitle
    case title
    case semiTitle
    case body
    case caption
    
    var size: CGFloat {
        switch self {
        case .largeTitle:
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
    
    var weight: UIFont.Weight {
        switch self {
        case .largeTitle:
            return .bold
        case .title:
            return .semibold
        case .caption:
            return .medium
        default:
            return .regular
        }
    }
}
