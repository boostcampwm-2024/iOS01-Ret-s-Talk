//
//  AppVersionView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/26/24.
//

import SwiftUI

extension UserSettingView {
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
    enum Texts {
        static let appVersionViewTitle = "앱 버전"
        static let appVersionViewBundleKey = "CFBundleShortVersionString"
        static let appVersionDefaultValue = "1.0"
    }
}
