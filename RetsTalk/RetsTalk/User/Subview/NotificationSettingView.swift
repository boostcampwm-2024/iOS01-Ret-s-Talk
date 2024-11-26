//
//  NotificationSettingView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/26/24.
//

import SwiftUI

extension UserSettingView {
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
}

// MARK: - Constants

private extension UserSettingView {
    enum Texts {
        static let notificationSettingViewToggleTitle = "회고 작성 알림"
        static let notificationSettingViewDatePickerTitle = "시간"
    }
}
