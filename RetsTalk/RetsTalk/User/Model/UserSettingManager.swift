//
//  UserSettingManager.swift
//  RetsTalk
//
//  Created by HanSeung on 11/25/24.
//

import Combine

final class UserSettingManager: UserSettingManageable, @unchecked Sendable {
    private var userData: UserData {
        didSet { userDataSubject.send(userData) }
    }
    private(set) var userDataSubject: CurrentValueSubject<UserData, Never>
    private let userDataStorage: Persistable
    
    // MARK: Init method
    
    init(userData: UserData, persistent: Persistable) {
        self.userData = userData
        self.userDataSubject = CurrentValueSubject(userData)
        self.userDataStorage = persistent
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
            
            userData = fetchedData
        }
    }
    
    func update(to userData: UserData) {
        Task {
            self.userData = try await userDataStorage.update(from: userData, to: userData)
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
