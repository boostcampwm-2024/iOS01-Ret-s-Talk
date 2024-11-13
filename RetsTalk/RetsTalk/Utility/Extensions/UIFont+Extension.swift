//
//  UIFont+Extension.swift
//  RetsTalk
//
//  Created by HanSeung on 11/13/24.
//

import UIKit

extension UIFont {
    static func appFont(_ appFont: FontSet) -> UIFont {
        return UIFont.systemFont(ofSize: appFont.size)
    }
}
