//
//  OnBoardingView.swift
//  RetsTalk
//
//  Created by HanSeung on 11/30/24.
//

import SwiftUI

struct OnBoardingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text(Texts.onBoardingViewTitle)
                .font(Font(UIFont.appFont(.largeTitle)))
                .padding()
            VStack(alignment: .leading) {
                OnBoardingGuideItem(
                    imageName: Texts.chatIconName,
                    title: Texts.chatItemTitle,
                    content: Texts.chatItemContent
                )
                OnBoardingGuideItem(
                    imageName: Texts.pinIconName,
                    title: Texts.pinItemTitle,
                    content: Texts.pinItemContent
                )
                OnBoardingGuideItem(
                    imageName: Texts.iCloucIconName,
                    title: Texts.iCloucItemTitle,
                    content: Texts.iCloucItemContent
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Metrics.onBoardingGuideItemListPadding)
            Spacer()
            ContinueButton {
                dismiss()
            }
        }
        .padding(Metrics.onBoardingViewPadding)
    }
}

private extension OnBoardingView {
    struct ContinueButton: View {
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(Texts.continueButtonTitle)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Metrics.continueButtonPadding)
                    .background(Color.blazingOrange)
                    .cornerRadius(Metrics.continueButtonCornerRadius)
            }
        }
        
    }
    
    struct OnBoardingGuideItem: View {
        let imageName: String
        let title: String
        let content: String

        var body: some View {
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.blazingOrange)
                    .frame(
                        width: Metrics.onBoardingGuideItemImageSize,
                        height: Metrics.onBoardingGuideItemImageSize
                    )
                VStack(alignment: .leading) {
                    Text(title)
                        .bold()
                    Text(content)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, Metrics.onBoardingGuideItemMargin)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Metrics.onBoardingGuideItemPadding)
        }
    }
}

private extension OnBoardingView {
    enum Metrics {
        static let onBoardingViewPadding = 40.0

        static let onBoardingGuideItemListPadding = 32.0
        static let onBoardingGuideItemImageSize = 40.0
        static let onBoardingGuideItemPadding = 8.0
        static let onBoardingGuideItemMargin = 4.0
        
        static let continueButtonPadding = 16.0
        static let continueButtonCornerRadius = 12.0
    }
    enum Texts {
        static let onBoardingViewTitle = "레츠톡 시작하기"
        
        static let chatIconName = "bubble.left.and.text.bubble.right.fill"
        static let chatItemTitle = "대화로 회고하기"
        static let chatItemContent = "하루를 되돌아보며 레츠톡과 함께 대화해보세요."
        
        static let pinIconName = "pin.fill"
        static let pinItemTitle = "회고 고정하기"
        static let pinItemContent = "중요한 회고를 상단에 고정하세요. 인상깊은 회고를 언제든지 돌아볼 수 있습니다."
        
        static let iCloucIconName = "person.icloud.fill"
        static let iCloucItemTitle = "iCloud 동기화"
        static let iCloucItemContent = "iCloud를 통해 내 기기간 데이터를 동기화하고 다른 기기에서도 사용할 수 있습니다."
        
        static let continueButtonTitle = "계속하기"
    }
}

#Preview {
    OnBoardingView()
}
