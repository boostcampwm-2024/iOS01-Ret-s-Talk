//
//  CloudSettingView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/26/24.
//

import SwiftUI

extension UserSettingView {
    struct CloudSettingView: View {
        @Binding var isCloudSyncOn: Bool
        @Binding var cloudAddress: String
        var action: () -> Void
        
        var body: some View {
            HStack {
                Text(UserSettingViewTexts.cloudSettingViewTitle)
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
}

// MARK: - Constants

private extension UserSettingViewTexts {
    static let cloudSettingViewTitle = "클라우드 동기화"
}
