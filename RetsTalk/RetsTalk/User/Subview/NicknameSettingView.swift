//
//  NicknameSettingView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/26/24.
//

import SwiftUI

extension UserSettingView {
    struct NicknameSettingView: View {
        @Binding var nickname: String
        @State private var isShowingModal = false
        var action: (_ nickname: String) -> Void
        
        var body: some View {
            HStack {
                Text(Texts.nicknameSettingViewTitle)
                Spacer()
                Text(nickname)
                    .foregroundStyle(.secondary)
                NicknameEditButton(isShowingModal: $isShowingModal)
            }
            .sheet(isPresented: $isShowingModal) {
                NicknameModalView(action: { updatingNickname in
                    action(updatingNickname)
                })
                .presentationDetents([.fraction(Numerics.modalFraction)])
            }
        }
    }
    
    struct NicknameEditButton: View {
        @Binding var isShowingModal: Bool
        
        init(isShowingModal: Binding<Bool>) {
            self._isShowingModal = isShowingModal
        }
        
        var body: some View {
            Button(
                action: {
                    isShowingModal = true
                },
                label: {
                    Image(systemName: Texts.editButtonImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.blueBerry)
                        .frame(width: Metrics.editButtonSize)
                })
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Constants

private extension UserSettingView {
    enum Metrics {
        static let editButtonSize = 16.0
        static let horizontalPadding = 16.0
        static let verticalPadding = 8.0
    }
    
    enum Numerics {
        static let modalFraction = 0.3
    }
    
    enum Texts {
        static let editButtonImageName = "pencil"
        static let nicknameSettingViewTitle = "닉네임"
    }
}
