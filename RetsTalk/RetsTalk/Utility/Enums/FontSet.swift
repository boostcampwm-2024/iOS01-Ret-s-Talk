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
    case subtitle
    case semiTitle
    case body
    case caption
    
    var size: CGFloat {
        switch self {
        case .largeTitle:
            34
        case .title:
            22
        case .subtitle:
            16
        case .semiTitle:
            16
        case .body:
            14
        case .caption:
            11
        }
    }
    
    var weight: UIFont.Weight {
        switch self {
        case .largeTitle:
            UIFont.Weight.bold
        case .title:
            UIFont.Weight.bold
        case .subtitle:
            UIFont.Weight.bold
        case .caption:
            UIFont.Weight.medium
        default:
            UIFont.Weight.regular
        }
    }
}
