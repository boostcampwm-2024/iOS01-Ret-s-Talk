//
//  UserSettingManager.swift
//  RetsTalk
//
//  Created by HanSeung on 11/25/24.
//

import Combine
import Foundation

@MainActor
protocol UserSettingManageableAlertable: AnyObject {
    func needNotificationPermission(_ userSettingManageable: any UserSettingManageable)
    func checkICloudState(_ userSettingManageable: any UserSettingManageable)
}

@MainActor
protocol UserSettingManageableCloudDelegate: AnyObject {
    func didCloudSyncStateChange(_ userSettingManageable: any UserSettingManageable)
}

final class UserSettingManager: UserSettingManageable, ObservableObject {
    @Published var userData: UserData = .init(dictionary: [:])
    private let userDataStorage: Persistable
    private let notificationManager: NotificationManageable
    private let cloudKitManager: CloudKitManageable

    weak var alertable: UserSettingManageableAlertable?
    weak var cloudDelegate: UserSettingManageableCloudDelegate?

    // MARK: Init method
    
    init(userDataStorage: Persistable) {
        self.userDataStorage = userDataStorage
        notificationManager = NotificationManager()
        cloudKitManager = CloudKitManager()
    }
    
    // MARK: UserSettingManageable conformance
    
    func initialize() -> UUID? {
        do {
            let request = PersistFetchRequest<UserData>(fetchLimit: 1)
            let fetchedData = try userDataStorage.fetch(by: request)
            guard let storedUserData = fetchedData.first else { return initializeUserData() }

            userData = storedUserData
            return UUID(uuidString: userData.userID)
        } catch {
            return nil
        }
    }
    
    func fetch() {
        let request = PersistFetchRequest<UserData>(fetchLimit: 1)
        Task {
            let fetchedData = try userDataStorage.fetch(by: request)
            guard let storedUserData = fetchedData.first else { return }
            
            await MainActor.run {
                userData = storedUserData
            }
        }
    }
    
    func updateNickname(_ nickname: String) {
        updateUserData { $0.nickname = nickname }
    }
    
    func updateCloudSyncState(state isOn: Bool) {
        Task {
            guard let recordID = await cloudKitManager.fetchRecordIDIfIcloudEnabled()
                else {
                updateUserData {
                    $0.isCloudSyncOn = false
                    $0.cloudAddress = ""
                }
                alertable?.checkICloudState(self)
                return
            }

            updateUserData {
                $0.isCloudSyncOn = isOn
                $0.cloudAddress = recordID
            }
            cloudDelegate?.didCloudSyncStateChange(self)
        }
    }
    
    func updateNotificationStatus(_ isOn: Bool, at date: Date) {
        Task {
            let isNotificationAllowed = await notificationManager.requestNotification(isOn, date: date)
            updateUserData { userData in
                userData.isNotificationOn = isNotificationAllowed ? isOn : false
                userData.notificationTime = date
            }
            if !isNotificationAllowed { alertable?.needNotificationPermission(self) }
        }
    }
    
    // MARK: UserData Handling Method

    private func updateUserData(_ updateBlock: @escaping (inout UserData) -> Void) {
        Task { @MainActor in
            var latestUserData = userData
            updateBlock(&latestUserData)
            let updatedData = try userDataStorage.update(from: userData, to: latestUserData)
            userData = updatedData
        }
    }

    private func initializeUserData() -> UUID {
        let newUserID = UUID()
        let newNickname = randomNickname()
        let newUserData = UserData(dictionary: ["userID": newUserID.uuidString, "nickname": newNickname])
        Task {
            let addedData = try userDataStorage.add(contentsOf: [newUserData])
            guard let addedData = addedData.first else { return }
            
            await MainActor.run {
                userData = addedData
            }
        }
        return newUserID
    }
    
    private func initiateUserData() {
        Task {
            let addedData = try userDataStorage.add(contentsOf: [UserData(dictionary: [:])])
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
