//
//  RetrospectCell.swift
//  RetsTalk
//
//  Created on 11/21/24.
//

import SwiftUI

struct RetrospectCell: View {
    let summary: String
    let createdAt: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            SummaryText(summary)
            Spacer()
                .frame(height: Metrics.padding)
            CreatedDateText(createdAt)
        }
        .padding(Metrics.padding)
        .background(Color(Texts.cellBackgroundColorName))
        .cornerRadius(Metrics.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                .stroke(Color(Texts.cellStrokeColorName), lineWidth: Metrics.RectangleStrokeWidth)
        )
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Subviews

private extension RetrospectCell {
    struct SummaryText: View {
        let content: String
        
        init(_ content: String) {
            self.content = content
        }
    
        var body: some View {
            HStack(alignment: .top) {
                Text(content.charWrapping)
                    .font(Font(UIFont.appFont(.semiTitle)))
                    .lineLimit(Numerics.summaryTextLineLimit)
                    .truncationMode(.tail)
                Spacer()
            }
            .frame(height: Numerics.summaryTextHeight, alignment: .topLeading)
        }
    }
    
    struct CreatedDateText: View {
        let date: Date
        
        init(_ date: Date) {
            self.date = date
        }
        
        var body: some View {
            Text(date.formattedToKoreanStyle)
                .font(Font(UIFont.appFont(.caption)))
                .foregroundStyle(.blueBerry)
        }
        
        }
    }

// MARK: - Constants

private extension RetrospectCell {
    enum Metrics {
        static let margin = 16.0
        static let padding = 10.0
        static let cornerRadius = 12.0
        static let RectangleStrokeWidth = 1.0
        static let summaryTextHeight = 40.0
    }
    
    enum Numerics {
        static let summaryTextLineLimit = 2
    }
    
    enum Texts {
        static let cellBackgroundColorName = "BackgroundRetrospect"
        static let cellStrokeColorName = "StrokeRetrospect"
    }
}

// MARK: - Preview

struct RetrospectView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("BackgroundMain").edgesIgnoringSafeArea(.all)
            VStack {
                RetrospectCell(summary: "디버깅에 지친 하루이다.", createdAt: Date())
                RetrospectCell(summary: "디버깅에 지친 하루였지만, 원인을 찾고 문제를 해결하면서 조금 더 단단해진 기분이다.", createdAt: Date())
            }
        }
    }
}
