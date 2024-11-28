//
//  UserSettingView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/24/24.
//

import SwiftUI

struct UserSettingView: View {
    @StateObject var userSettingManager: UserSettingManager
    
    var body: some View {
        List {
            Section(Texts.firstSectionTitle) {
                NicknameSettingView(nickname: $userSettingManager.userData.nickname) { updatingNickname in
                    setNickname(updatingNickname)
                }
            }
            
            Section(Texts.secondSectionTitle) {
                CloudSettingView(
                    isCloudSyncOn: $userSettingManager.userData.isCloudSyncOn,
                    cloudAddress: $userSettingManager.userData.cloudAddress,
                    action: { isOn in
                        setCloudSync(isOn)
                    }
                )
            }
            
            Section(Texts.thirdSectionTitle) {
                NotificationSettingView(
                    isNotificationOn: $userSettingManager.userData.isNotificationOn,
                    selectedDate: $userSettingManager.userData.notificationTime
                ) {
                    
                }
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
    func setCloudSync(_ isOn: Bool) {
        var userData = userSettingManager.userData
        userData.isCloudSyncOn = isOn
        userSettingManager.update(to: userData)
    }
    
    func setNickname(_ updatingNickname: String) {
        var updatingUserData = userSettingManager.userData
        updatingUserData.nickname = updatingNickname
        userSettingManager.update(to: updatingUserData)
    }
}

// MARK: - Constants

private extension UserSettingView {
    enum Texts {
        static let firstSectionTitle = "사용자 정보"
        static let secondSectionTitle = "클라우드"
        static let thirdSectionTitle = "알림"
        static let fourthSectionTitle = "앱 정보"
    }
}
