//
//  Color+Extension.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import SwiftUI

extension Color {
    init(hexCode: String) {
        let scanner = Scanner(string: hexCode)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >>  8) & 0xFF) / 255.0
        let blue = Double((rgb >>  0) & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    static func appColor(_ colorset: ColorSet) -> Color {
        return Color(hexCode: colorset.hexCode)
    }
}
