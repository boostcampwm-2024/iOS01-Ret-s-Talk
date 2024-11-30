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
        var onCloudSyncChange: (_ isOn: Bool) -> Void
        
        var body: some View {
            HStack {
                Text(Texts.cloudSettingViewTitle)
                Spacer()
                Toggle(isOn: $isCloudSyncOn) {}
                    .toggleStyle(SwitchToggleStyle(tint: .blazingOrange))
                    .onChange(of: isCloudSyncOn) { _ in
                        onCloudSyncChange(isCloudSyncOn)
                    }
            }
            
            if isCloudSyncOn {
                Text(cloudAddress)
                    .foregroundStyle(.gray)
            }
        }
    }
}

// MARK: - Constants

private extension UserSettingView {
    enum Texts {
        static let cloudSettingViewTitle = "클라우드 동기화"
    }
}
