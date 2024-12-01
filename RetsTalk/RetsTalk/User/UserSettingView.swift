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
                    toggleAction: { isOn, date in
                        requestNotification(isOn, at: date)
                    },
                    pickAction: { date in
                        requestNotification(at: date)
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

// MARK: - Custom method

private extension UserSettingView {
    func setCloudSync(_ isOn: Bool) {
        userSettingManager.updateCloudSyncState(state: isOn)
    }
    
    func setNickname(_ updatingNickname: String) {
        userSettingManager.updateNickname(updatingNickname)
    }
}

private extension UserSettingView {
    func requestNotification(_ isOn: Bool = true, at date: Date) {
        Task {
            var userData = userSettingManager.userData
            if isOn {
                notificationManager.checkAndRequestPermission { didAllow in
                    switch didAllow {
                    case true:
                        notificationManager.scheduleNotification(date: date)
                    case false:
                        notificationManager.cancelNotification()
                    }
                }
            } else {
                notificationManager.cancelNotification()
            }
            userData.isNotificationOn = isOn
            userSettingManager.update(to: userData)
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
