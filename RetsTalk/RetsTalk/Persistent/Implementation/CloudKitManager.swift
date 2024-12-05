//
//  CloudKitManager.swift
//  RetsTalk
//
//  Created by MoonGoon on 12/5/24.
//

import CloudKit

final class CloudKitManager: CloudKitManageable {
    private let container = CKContainer.default()

    func fetchRecordIDIfIcloudEnabled() async -> String? {
        do {
            let state = try await container.accountStatus()
            switch state {
            case .available:
                let recordID = try await container.userRecordID()
                return recordID.recordName
            default:
                return nil
            }
        } catch {
            return nil
        }
    }
}
