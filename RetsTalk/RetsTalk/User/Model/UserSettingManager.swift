//
//  UserSettingManager.swift
//  RetsTalk
//
//  Created by HanSeung on 11/25/24.
//

import Combine
import Foundation

final class UserSettingManager: UserSettingManageable, @unchecked Sendable, ObservableObject {
    @Published var userData: UserData = .init(dictionary: [:])
    private let userDataStorage: Persistable
    
    // MARK: Init method
    
    init(userDataStorage: Persistable) {
        self.userDataStorage = userDataStorage
    }
    
    // MARK: UserSettingManageable conformance
    
    func initialize() async -> UUID? {
        do {
            let request = PersistFetchRequest<UserData>(fetchLimit: 1)
            let fetchedData = try await userDataStorage.fetch(by: request)
            guard let storedUserData = fetchedData.first
            else { return initializeUserData() }
            
            await MainActor.run {
                userData = storedUserData
            }
            return UUID(uuidString: userData.userID)
        } catch {
            return nil
        }
    }
    
    func fetch() {
        let request = PersistFetchRequest<UserData>(fetchLimit: 1)
        Task {
            let fetchedData = try await userDataStorage.fetch(by: request)
            guard let storedUserData = fetchedData.first else { return }
            
            await MainActor.run {
                userData = storedUserData
            }
        }
    }
    
    func updateNickname(_ nickname: String) {
        var updatingUserData = userData
        updatingUserData.nickname = nickname
        update(to: updatingUserData)
    }
    
    func updateCloudSyncState(state isOn: Bool) {
        var updatingUserData = userData
        updatingUserData.isCloudSyncOn = isOn
        update(to: updatingUserData)
    }
    
    func updateNotificationStatus(_ isOn: Bool, at date: Date) {
        var updatingUserData = userData
        updatingUserData.isNotificationOn = isOn
        updatingUserData.notificationTime = date
        update(to: updatingUserData)
    }
    
    // MARK: UserData Handling Method
    
    private func update(to updatingData: UserData) {
        Task {
            let updatedData = try await userDataStorage.update(from: updatingData, to: updatingData)
            await MainActor.run {
                userData = updatedData
            }
        }
    }
    
    private func initializeUserData() -> UUID {
        let newUserID = UUID()
        let newNickname = randomNickname()
        let newUserData = UserData(dictionary: ["userID": newUserID.uuidString, "nickname": newNickname])
        Task {
            let addedData = try await userDataStorage.add(contentsOf: [newUserData])
            guard let addedData = addedData.first else { return }
            
            await MainActor.run {
                userData = addedData
            }
        }
        return newUserID
    }
    
    private func initiateUserData() {
        Task {
            let addedData = try await userDataStorage.add(contentsOf: [UserData(dictionary: [:])])
            guard let addedData = addedData.first else { return }
            
            await MainActor.run {
                userData = addedData
            }
        }
    }
    
    private func randomNickname() -> String {
        let adjective = Texts.nicknameComposingAdjectives.randomElement() ?? ""
        let noun = Texts.nicknameComposingNoun
        return adjective + " " + noun
    }
    
}

// MARK: - Constants

private extension UserSettingManager {
    enum Texts {
        static let nicknameComposingAdjectives = [
            "게임하는", "산책하는", "야근하는", "공상하는",
            "폭식하는", "달리는", "춤추는", "헤엄치는", "노래하는",
        ]
        static let nicknameComposingNoun = "부덕이"
        static var randomNickname: String {
            (nicknameComposingAdjectives.randomElement() ?? " ") + nicknameComposingNoun
        }
    }
}
