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
            .frame(height: 40, alignment: .topLeading)
        }
    }
    
    struct CreatedDateText: View {
        let date: Date
        
        init(_ date: Date) {
            self.date = date
        }
        
        var body: some View {
            Text(formatDateToKoreanStyle(date: date))
                .font(Font(UIFont.appFont(.caption)))
                .foregroundStyle(.blueBerry)
        }
        
        private func formatDateToKoreanStyle(date: Date) -> String {
            let calendar = Calendar.current
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: Texts.dateLocaleIdentifier)
            
            switch date {
            case _ where calendar.isDateInToday(date):
                dateFormatter.dateFormat = Texts.dateFormatRecent
                return dateFormatter.string(from: date)
            case _ where calendar.isDateInYesterday(date):
                return Texts.dateFormatYesterday
            default:
                dateFormatter.dateFormat = Texts.dateFormat
                return dateFormatter.string(from: date)
            }
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
    }
    
    enum Numerics {
        static let summaryTextLineLimit = 2
    }
    
    enum Texts {
        static let cellBackgroundColorName = "BackgroundRetrospect"
        static let cellStrokeColorName = "StrokeRetrospect"
        
        static let dateLocaleIdentifier = "ko_KR"
        static let dateFormat = "M월 d일 EEEE"
        static let dateFormatRecent = "오늘 a h:mm"
        static let dateFormatYesterday = "어제"
    }
}

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
