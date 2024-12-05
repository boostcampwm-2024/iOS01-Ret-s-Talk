//
//  UserSettingView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/24/24.
//

import SwiftUI

struct UserSettingView<Manageable: UserSettingManageable>: View {
    @ObservedObject var userSettingManager: Manageable

    init(userSettingManager: Manageable) {
        self.userSettingManager = userSettingManager
    }
    
    var body: some View {
        List {
            Section(UserSettingViewTexts.userInfo) {
                NicknameSettingView(nickname: $userSettingManager.userData.nickname) { updatingNickname in
                    setNickname(updatingNickname)
                }
            }
            
            Section(UserSettingViewTexts.iCloud) {
                CloudSettingView(
                    isCloudSyncOn: $userSettingManager.userData.isCloudSyncOn,
                    cloudAddress: $userSettingManager.userData.cloudAddress,
                    onCloudSyncChange: { isOn in
                        setCloudSync(isOn)
                    }
                )
            }
            
            Section(UserSettingViewTexts.notification) {
                NotificationSettingView(
                    isNotificationOn: $userSettingManager.userData.isNotificationOn,
                    selectedDate: $userSettingManager.userData.notificationTime,
                    action: { isOn, date in
                        setNotification(isOn, at: date)
                    }
                )
            }
            
            Section(UserSettingViewTexts.applicationInfo) {
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
        userSettingManager.updateNotificationStatus(isOn, at: date)
    }
}

// MARK: - Constants

private extension UserSettingViewTexts {
    static let userInfo = "사용자 정보"
    static let iCloud = "클라우드"
    static let notification = "알림"
    static let applicationInfo = "앱 정보"
}
