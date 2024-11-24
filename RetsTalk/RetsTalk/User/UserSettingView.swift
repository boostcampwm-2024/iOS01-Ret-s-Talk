//
//  UserSettingView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/24/24.
//

import SwiftUI

struct UserSettingView: View {
    @State private var isOn = true
    @State private var selectedDate = Date()
    
    var body: some View {
        List {
            Section("사용자 정보") {
                HStack {
                    Text("폭식하는 부덕이")
                    Spacer()
                    Button(action: {}, label: {
                        Image(systemName: "pencil")
                            .resizable()
                            .aspectRatio(contentMode: .fit)  // 비율 유지
                            .foregroundColor(.blazingOrange)
                            .frame(width: 18)
                    })
                }
            }
            
            Section("클라우드") {
                HStack {
                    Text("클라우드 동기화")
                    Spacer()
                    Toggle(isOn: $isOn) {}
                        .toggleStyle(SwitchToggleStyle(tint: .blazingOrange))
                }
                Text("example@apple.com")
                    .foregroundStyle(.gray)
            }
            
            Section("알림") {
                HStack {
                    Text("회고 작성 알림")
                    Spacer()
                    Toggle(isOn: $isOn) {}
                        .toggleStyle(SwitchToggleStyle(tint: .blazingOrange))
                }
                
                if isOn {
                    DatePicker("시간", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        .tint(.blazingOrange)
                }
            }
            
            Section("앱 정보") {
                HStack {
                    Text("앱 버전")
                    Spacer()
                    Text("1.1")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    UserSettingView()
}
