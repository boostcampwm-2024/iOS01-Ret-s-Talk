//
//  UserSettingView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/24/24.
//

import SwiftUI

struct UserSettingView<Manageable: UserSettingManageable>: View {
    @ObservedObject var userSettingManager: Manageable
    private let notificationManager: NotificationManageable
    
    init(userSettingManager: Manageable, notificationManager: NotificationManageable) {
        self.userSettingManager = userSettingManager
        self.notificationManager = notificationManager
    }
    
    var body: some View {
        List {
            Section(UserSettingViewTexts.firstSectionTitle) {
                NicknameSettingView(nickname: $userSettingManager.userData.nickname) { updatingNickname in
                    setNickname(updatingNickname)
                }
            }
            
            Section(UserSettingViewTexts.secondSectionTitle) {
                CloudSettingView(
                    isCloudSyncOn: $userSettingManager.userData.isCloudSyncOn,
                    cloudAddress: $userSettingManager.userData.cloudAddress,
                    onCloudSyncChange: { isOn in
                        setCloudSync(isOn)
                    }
                )
            }
            
            Section(UserSettingViewTexts.thirdSectionTitle) {
                NotificationSettingView(
                    isNotificationOn: $userSettingManager.userData.isNotificationOn,
                    selectedDate: $userSettingManager.userData.notificationTime,
                    action: { isOn, date in
                        setNotification(isOn, at: date)
                    }
                )
            }
            
            Section(UserSettingViewTexts.fourthSectionTitle) {
                AppVersionView()
            }
        }
        .onAppear {
            userSettingManager.fetch()
        }
    }
}

// MARK: - UserData setting method

private extension UserSettingView {
    func setCloudSync(_ isOn: Bool) {
        userSettingManager.updateCloudSyncState(state: isOn)
    }
    
    func setNickname(_ updatingNickname: String) {
        userSettingManager.updateNickname(updatingNickname)
    }

    func setNotification(_ isOn: Bool, at date: Date) {
        notificationManager.requestNotification(isOn, date: date) { [userSettingManager] completion in
            userSettingManager.updateNotificationStatus(completion, at: date)
        }
    }
}

// MARK: - Constants

private extension UserSettingViewTexts {
    static let firstSectionTitle = "사용자 정보"
    static let secondSectionTitle = "클라우드"
    static let thirdSectionTitle = "알림"
    static let fourthSectionTitle = "앱 정보"
}
