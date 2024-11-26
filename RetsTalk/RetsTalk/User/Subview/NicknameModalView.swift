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
                NicknameModalTextField(Texts.nicknameModalPlaceholder, text: $nickname)
                NicknameModalDoneButton(action: {
                    action(nickname)
                    dismiss()
                })
                .disabled(nickname.isEmpty)
                .opacity(nickname.isEmpty ? Numerics.doneButtonDisabledOpaque : Numerics.doneButtonDefaultOpaque)
            }
        }
    }
    
    struct NicknameModalTitleText: View {
        var body: some View {
            Text(Texts.nicknameModalTitle)
                .font(.headline)
                .padding(.vertical, Metrics.verticalPadding)
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
                .padding(Metrics.horizontalPadding)
                .frame(height: Metrics.nicknameModalDoneButtonHeight)
                .background(Color.backgroundMain)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.nicknameModalCornerRadius))
                .padding(.horizontal, Metrics.horizontalPadding)
                .padding(.vertical, Metrics.verticalPadding)
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
        }
    }
}

// MARK: - Constants

private extension UserSettingView {
    enum Metrics {
        static let horizontalPadding = 16.0
        static let verticalPadding = 8.0
        static let nicknameModalDoneButtonHeight = 52.0
        static let nicknameModalCornerRadius = nicknameModalDoneButtonHeight / 2
    }
    
    enum Numerics {
        static let doneButtonDisabledOpaque =  0.5
        static let doneButtonDefaultOpaque = 1.0
    }
    
    enum Texts {
        static let nicknameModalTitle = "닉네임 변경"
        static let nicknameModalPlaceholder = "새로운 닉네임을 입력하세요"
        static let nicknameModalDoneButtonTitle = "완료"
    }
}
