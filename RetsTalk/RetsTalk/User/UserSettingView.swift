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

// MARK: - Subviews

private extension UserSettingView {
    struct NicknameSettingView: View {
        @Binding var nickname: String
        @State private var isShowingModal = false
        var action: (_ nickname: String) -> Void
        
        var body: some View {
            HStack {
                Text(nickname)
                Spacer()
                Button(
                    action: {
                        isShowingModal = true
                    },
                    label: {
                        Image(systemName: Texts.editButtonImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.blazingOrange)
                            .frame(width: Metrics.editButtonSize)
                    })
                .buttonStyle(PlainButtonStyle())
            }
            .sheet(isPresented: $isShowingModal) {
                NicknameModalView(action: { updatingNickname in
                    action(updatingNickname)
                })
                .presentationDetents([.fraction(Numerics.modalFraction)])
            }
        }
    }
    
    struct NicknameModalView: View {
        @State var nickname: String = ""
        @Environment(\.dismiss) var dismiss
        var action: (_ nickname: String) -> Void
        
        var body: some View {
            VStack {
                Text(Texts.nicknameModalTitle)
                    .font(.headline)
                    .padding(.vertical, Metrics.verticalPadding)
                
                TextField(Texts.nicknameModalPlaceholder, text: $nickname)
                    .padding(Metrics.horizontalPadding)
                    .frame(height: Metrics.nicknameModalDoneButtonHeight)
                    .background(Color.backgroundMain)
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.nicknameModalCornerRadius))
                    .padding(.horizontal, Metrics.horizontalPadding)
                    .padding(.vertical, Metrics.verticalPadding)
                
                Button(
                    action: {
                        action(nickname)
                        dismiss()
                    },
                    label: {
                        ZStack {
                            Color.blazingOrange
                                .clipShape(RoundedRectangle(cornerRadius: Metrics.nicknameModalCornerRadius))
                            Text(Texts.nicknameModalDoneButtonTitle)
                                .foregroundStyle(.white)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.nicknameModalDoneButtonHeight)
                        .padding(.horizontal, Metrics.horizontalPadding)
                        .padding(.vertical, Metrics.verticalPadding)
                    })
                .disabled(nickname.isEmpty)
                .opacity(nickname.isEmpty ? Numerics.doneButtonDisabledOpaque : Numerics.doneButtonDefaultOpaque)
            }
        }
    }
    
    struct CloudSettingView: View {
        @Binding var isCloudSyncOn: Bool
        @Binding var cloudAddress: String
        var action: () -> Void
        
        var body: some View {
            HStack {
                Text(Texts.cloudSettingViewTitle)
                Spacer()
                Toggle(isOn: $isCloudSyncOn) {}
                    .toggleStyle(SwitchToggleStyle(tint: .blazingOrange))
            }
            
            if isCloudSyncOn {
                Text(cloudAddress)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    struct NotificationSettingView: View {
        @Binding var isNotificationOn: Bool
        @Binding var selectedDate: Date
        var action: () -> Void
        
        var body: some View {
            HStack {
                Text(Texts.notificationSettingViewToggleTitle)
                Spacer()
                Toggle(isOn: $isNotificationOn) {}
                    .toggleStyle(SwitchToggleStyle(tint: .blazingOrange))
                    .onChange(of: isNotificationOn) { _ in
                        action()
                    }
            }
            
            if isNotificationOn {
                DatePicker(
                    Texts.notificationSettingViewDatePickerTitle,
                    selection: $selectedDate,
                    displayedComponents: .hourAndMinute
                )
                .tint(.blazingOrange)
                .onChange(of: selectedDate) { _ in
                    action()
                }
            }
        }
    }
    
    struct AppVersionView: View {
        private var appVersion: String? =  Bundle.main.infoDictionary?[Texts.appVersionViewBundleKey] as? String
        
        var body: some View {
            HStack {
                Text(Texts.appVersionViewTitle)
                Spacer()
                Text(appVersion ?? Texts.appVersionDefaultValue)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Constants

private extension UserSettingView {
    enum Metrics {
        static let editButtonSize = 18.0
        static let horizontalPadding = 16.0
        static let verticalPadding = 8.0
        
        static let nicknameModalDoneButtonHeight = 52.0
        static let nicknameModalCornerRadius = nicknameModalDoneButtonHeight / 2
    }
    
    enum Numerics {
        static let modalFraction = 0.3
        static let doneButtonDisabledOpaque =  0.5
        static let doneButtonDefaultOpaque = 1.0
    }
    
    enum Texts {
        static let editButtonImageName = "pencil"
        
        static let firstSectionTitle = "사용자 정보"
        static let secondSectionTitle = "클라우드"
        static let thirdSectionTitle = "알림"
        static let fourthSectionTitle = "앱 정보"
        
        static let cloudSettingViewTitle = "클라우드 동기화"
        static let notificationSettingViewToggleTitle = "회고 작성 알림"
        static let notificationSettingViewDatePickerTitle = "시간"
        static let appVersionViewTitle = "앱 버전"
        static let appVersionViewBundleKey = "CFBundleShortVersionString"
        static let appVersionDefaultValue = "1.0"
        
        static let nicknameModalTitle = "닉네임 변경"
        static let nicknameModalPlaceholder = "새로운 닉네임을 입력하세요"
        static let nicknameModalDoneButtonTitle = "완료"
    }
}
