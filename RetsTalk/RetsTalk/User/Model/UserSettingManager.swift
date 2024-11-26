//
//  UserSettingManager.swift
//  RetsTalk
//
//  Created by HanSeung on 11/25/24.
//

import Combine

final class UserSettingManager: UserSettingManageable, @unchecked Sendable, ObservableObject {
    @Published var userData: UserData = .init(dictionary: [:])
    private let userDataStorage: Persistable
    
    // MARK: Init method
    
    init(persistent: Persistable) {
        userDataStorage = persistent
    }
    
    // MARK: UserSettingManageable conformance
    
    func fetch() {
        let request = PersistFetchRequest<UserData>(fetchLimit: 1)
        Task {
            let fetchedData = try await userDataStorage.fetch(by: request)
            guard fetchedData.isNotEmpty, let fetchedData = fetchedData.first else {
                initiateUserData()
                return
            }
            
            await MainActor.run {
                userData = fetchedData
            }
        }
    }
    
    func update(to updatingData: UserData) {
        Task {
            let updatedData = try await userDataStorage.update(from: updatingData, to: updatingData)
            await MainActor.run {
                userData = updatedData
            }
        }
    }
    
    private func initiateUserData() {
        Task {
            let addedData = try await userDataStorage.add(contentsOf: [UserData(dictionary: [:])])
            guard let addedData = addedData.first else { return }
            
            userData = addedData
        }
    }
}