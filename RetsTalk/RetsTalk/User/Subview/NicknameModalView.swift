//
//  NicknameModalView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/26/24.
//

import SwiftUI

extension UserSettingView {
    struct NicknameModalView: View {
        @State var nickname: String = ""
        @Environment(\.dismiss) var dismiss
        var action: (_ nickname: String) -> Void
        
        var body: some View {
            VStack {
                NicknameModalTitleText()
                NicknameModalTextField(UserSettingViewTexts.nicknameModalPlaceholder, text: $nickname)
                NicknameModalDoneButton(action: {
                    action(nickname)
                    dismiss()
                })
                .disabled(nickname.isEmpty)
                .opacity(
                    nickname.isEmpty
                    ? UserSettingViewNumerics.doneButtonDisabledOpaque
                    : UserSettingViewNumerics.doneButtonDefaultOpaque
                )
            }
        }
    }
    
    struct NicknameModalTitleText: View {
        var body: some View {
            Text(UserSettingViewTexts.nicknameModalTitle)
                .font(.headline)
                .padding(.vertical, UserSettingViewMetrics.verticalPadding)
        }
    }
    
    struct NicknameModalTextField: View {
        let placeholder: String
        @Binding var text: String
        
        init(_ placeholder: String, text: Binding<String>) {
            self.placeholder = placeholder
            self._text = text
        }
        
        var body: some View {
            TextField(placeholder, text: $text)
                .padding(UserSettingViewMetrics.horizontalPadding)
                .frame(height: UserSettingViewMetrics.nicknameModalDoneButtonHeight)
                .background(Color.backgroundMain)
                .clipShape(RoundedRectangle(cornerRadius: UserSettingViewMetrics.nicknameModalCornerRadius))
                .padding(.horizontal, UserSettingViewMetrics.horizontalPadding)
                .padding(.vertical, UserSettingViewMetrics.verticalPadding)
        }
    }
    
    struct NicknameModalDoneButton: View {
        var action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        var body: some View {
            Button(action: {
                action()
            }, label:
                    {
                ZStack {
                    Color.blazingOrange
                        .clipShape(RoundedRectangle(cornerRadius: UserSettingViewMetrics.nicknameModalCornerRadius))
                    Text(UserSettingViewTexts.nicknameModalDoneButtonTitle)
                        .foregroundStyle(.white)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: UserSettingViewMetrics.nicknameModalDoneButtonHeight)
                .padding(.horizontal, UserSettingViewMetrics.horizontalPadding)
                .padding(.vertical, UserSettingViewMetrics.verticalPadding)
            })
        }
    }
}

// MARK: - Constants

private extension UserSettingViewMetrics {
    static let horizontalPadding = 16.0
    static let verticalPadding = 8.0
    static let nicknameModalDoneButtonHeight = 52.0
    static let nicknameModalCornerRadius = nicknameModalDoneButtonHeight / 2
}

private extension UserSettingViewNumerics {
    static let doneButtonDisabledOpaque =  0.5
    static let doneButtonDefaultOpaque = 1.0
}

private extension UserSettingViewTexts {
    static let nicknameModalTitle = "닉네임 변경"
    static let nicknameModalPlaceholder = "새로운 닉네임을 입력하세요"
    static let nicknameModalDoneButtonTitle = "완료"
}
