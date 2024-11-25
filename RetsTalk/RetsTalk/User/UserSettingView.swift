//
//  UserSettingView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/24/24.
//

import SwiftUI

@MainActor
protocol UserSettingViewDelegate: AnyObject {
    func didChangeNickname(_ userSettingView: UserSettingView, nickname: String)
    func didToggleCloudSync(_ userSettingView: UserSettingView, isOn: Bool)
    func didToggleNotification(_ userSettingView: UserSettingView, isOn: Bool, selectedDate: Date)
}

struct UserSettingView: View {
    var delegate: UserSettingViewDelegate?
    
    @State private var isCloudSyncOn = true
    @State private var isNotificationOn = false
    @State private var selectedDate = Date()
    @State private var cloudAddress: String = "example@apple.com" // 모델 연결 전
    @State private var nickname: String = "폭식하는 부덕이" // 모델 연결 전
    
    var body: some View {
        List {
            Section(Texts.firstSectionTitle) {
                NicknameSettingView(nickname: $nickname) {
                    // Alert 구현 전
                    delegate?.didChangeNickname(self, nickname: nickname)
                }
            }
            
            Section(Texts.secondSectionTitle) {
                CloudSettingView(isCloudSyncOn: $isCloudSyncOn, cloudAddress: $cloudAddress) {
                    delegate?.didToggleCloudSync(self, isOn: isCloudSyncOn)
                }
            }
            
            Section(Texts.thirdSectionTitle) {
                NotificationSettingView(isNotificationOn: $isNotificationOn, selectedDate: $selectedDate) {
                    delegate?.didToggleNotification(self, isOn: isNotificationOn, selectedDate: selectedDate)
                }
            }
            
            Section(Texts.fourthSectionTitle) {
                AppVersionView()
            }
        }
    }
}

private extension UserSettingView {
    struct NicknameSettingView: View {
        @Binding var nickname: String
        var action: () -> Void
        
        var body: some View {
            HStack {
                Text(nickname)
                Spacer()
                Button(action: action,
                       label: {
                    Image(systemName: Texts.editButtonImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.blazingOrange)
                        .frame(width: Metrics.editButtonSize)
                })
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
    }
}

// MARK: - Preview

#Preview {
    UserSettingView()
}
