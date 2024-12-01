//
//  UserSettingView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/24/24.
//

import SwiftUI

struct UserSettingView<T: UserSettingManageable>: View {
    @ObservedObject var userSettingManager: T
    private let notificationManager: NotificationManageable
    
    init(userSettingManager: T, notificationManager: NotificationManageable) {
        self.userSettingManager = userSettingManager
        self.notificationManager = notificationManager
    }
    
    var body: some View {
        List {
            Section(Texts.firstSectionTitle) {
                NicknameSettingView(nickname: $userSettingManager.userData.nickname) { updatingNickname in
                    var updatingUserData = userSettingManager.userData
                    updatingUserData.nickname = updatingNickname
                    userSettingManager.update(to: updatingUserData)
                }
            }
            
            Section(Texts.secondSectionTitle) {
                CloudSettingView(
                    isCloudSyncOn: $userSettingManager.userData.isCloudSyncOn,
                    cloudAddress: $userSettingManager.userData.cloudAddress
                ) {
                    
                }
            }
            
            Section(Texts.thirdSectionTitle) {
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
            
            Section(Texts.fourthSectionTitle) {
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

enum Texts {
    static let firstSectionTitle = "사용자 정보"
    static let secondSectionTitle = "클라우드"
    static let thirdSectionTitle = "알림"
    static let fourthSectionTitle = "앱 정보"
}
