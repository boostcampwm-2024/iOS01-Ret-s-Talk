//
//  CloudKitManageable.swift
//  RetsTalk
//
//  Created by MoonGoon on 12/5/24.
//

import CloudKit

protocol CloudKitManageable: Sendable {
    func fetchRecordIDIfIcloudEnabled() async -> String?
}
