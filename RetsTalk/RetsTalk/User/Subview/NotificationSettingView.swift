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
        var action: (_ isNotificationOn: Bool, _ date: Date) -> Void
        
        var body: some View {
            HStack {
                Text(UserSettingViewTexts.notificationSettingViewToggleTitle)
                Spacer()
                Toggle(isOn: $isNotificationOn) {}
                    .toggleStyle(SwitchToggleStyle(tint: .blazingOrange))
                    .onChange(of: isNotificationOn) { newValue in
                        action(newValue, selectedDate)
                    }
            }
            
            if isNotificationOn {
                DatePicker(
                    UserSettingViewTexts.notificationSettingViewDatePickerTitle,
                    selection: $selectedDate,
                    displayedComponents: .hourAndMinute
                )
                .tint(.blazingOrange)
                .onChange(of: selectedDate) { selectedDate in
                    action(isNotificationOn, selectedDate)
                }
            }
        }
    }
}

// MARK: - Constants

private extension UserSettingViewTexts {
    static let notificationSettingViewToggleTitle = "회고 작성 알림"
    static let notificationSettingViewDatePickerTitle = "시간"
}
