//
//  Font+Extension.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/14/24.
//

import SwiftUI

extension Font {
    static func appFont(_ appFont: FontSet) -> Font {
        return .system(size: appFont.size)
    }
}
