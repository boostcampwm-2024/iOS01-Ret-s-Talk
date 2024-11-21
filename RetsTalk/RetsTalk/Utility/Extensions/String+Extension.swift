//
//  String+Extension.swift
//  RetsTalk
//

extension String {
    var isNotEmpty: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var charWrapping: String {
        String(self.reduce("") { $0 + String($1) + "\u{200B}" }.dropLast())
    }
        
}
