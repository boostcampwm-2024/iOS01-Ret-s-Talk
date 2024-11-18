//
//  UserTableViewCell.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import SwiftUI

struct MessageCell: View {
    let message: String
    let isUser: Bool
    
    var body: some View {
        Text(message)
            .font(.appFont(.body))
            .padding(Metrics.textPadding)
            .background(isUser ? Color.appColor(.blueberry) : Color.appColor(.backgroundRetrospect))
            .foregroundColor(isUser ? .white : Color.appColor(.blueberry))
            .cornerRadius(Metrics.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                    .stroke(
                        isUser ? Color.appColor(.blueberry): Color.appColor(.strokeRetrospect),
                        lineWidth: Metrics.RectangleStrokeWidth
                    )
            )
            .frame(
                maxWidth: .infinity,
                alignment: isUser ? .trailing : .leading
            )
            .padding(isUser ? .leading : .trailing, Metrics.sidePadding)
    }
    
    private enum Metrics {
        static let textPadding = 8.0
        static let cornerRadius = 10.0
        static let RectangleStrokeWidth = 1.0
        static let sidePadding = 80.0
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MessageCell(message: "오늘 하루는 어떠셨나요?", isUser: false)
            MessageCell(message: "오늘은 Chatting View를 구현했어요", isUser: true)
            MessageCell(message: "어떻게 구현하셨나요?", isUser: false)
            MessageCell(message: "잘 구현을 했는데 어려운 부분이 많았지만 내일까지 계속해서 진행해야할 것 같아요", isUser: true)
        }
        .padding()
    }
}
