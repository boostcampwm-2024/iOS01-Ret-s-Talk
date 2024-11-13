//
//  UIColor+Extension.swift
//  RetsTalk
//
//  Created by HanSeung on 11/13/24.
//
import UIKit

extension UIColor {
    convenience init(hexCode: String) {
        var rgbValue: UInt64 = 0
        Scanner(string: hexCode).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    static func appColor(_ colorset: ColorSet) -> UIColor {
        return UIColor(hexCode: colorset.hexCode)
    }
}
