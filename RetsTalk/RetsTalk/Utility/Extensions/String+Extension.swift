//
//  String+Extension.swift
//  RetsTalk
//
//  Created by HanSeung on 11/20/24.
//

extension String {
    var charWrapping: String {
        return String(self.reduce("") { $0 + String($1) + "\u{200B}" }.dropLast())
    }
}
