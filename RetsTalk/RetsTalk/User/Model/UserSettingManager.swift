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
    
    func fetch() async throws {
        // request 임시 생성
        let request = PersistfetchRequest<UserData>(fetchLimit: 1)
        userData = try await userDataStorage.fetch(by: request)[0]
    }
    
    func update(to: UserData) async throws {
        userData = try await userDataStorage.update(from: userData, to: userData)
    }
}
