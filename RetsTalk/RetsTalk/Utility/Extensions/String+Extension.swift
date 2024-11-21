//
//  String+Extension.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/21/24.
//

extension String {
    var isNotEmpty: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
