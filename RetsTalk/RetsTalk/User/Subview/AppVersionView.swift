//
//  AppVersionView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/26/24.
//

import SwiftUI

extension UserSettingView {
    struct AppVersionView: View {
        private var appVersion: String? =  Bundle.main.infoDictionary?[UserSettingViewTexts.bundleKey] as? String
        
        var body: some View {
            HStack {
                Text(UserSettingViewTexts.appVersionViewTitle)
                Spacer()
                Text(appVersion ?? UserSettingViewTexts.appVersionDefaultValue)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Constants

private extension UserSettingViewTexts {
    static let appVersionViewTitle = "앱 버전"
    static let bundleKey = "CFBundleShortVersionString"
    static let appVersionDefaultValue = "1.0"
}
