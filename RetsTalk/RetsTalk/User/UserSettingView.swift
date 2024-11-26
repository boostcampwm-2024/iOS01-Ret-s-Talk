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

// MARK: - Constants

private extension UserSettingView {
    enum Texts {
        static let firstSectionTitle = "사용자 정보"
        static let secondSectionTitle = "클라우드"
        static let thirdSectionTitle = "알림"
        static let fourthSectionTitle = "앱 정보"
    }
}
