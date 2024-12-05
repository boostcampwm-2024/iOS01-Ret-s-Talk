//
//  Constants.swift
//  RetsTalk
//
//  Created by HanSeung on 11/21/24.
//

import Foundation

enum Constants {
    enum Texts {
        static let coreDataContainerName = "RetsTalk"
        static let retrospectCellIdentifier = "RetrospectCell"
        static let messageCellIdentifier = "MessageCell"
    }

    static let dateLocaleIdentifier = "ko_KR"
    static let dateFormat = "M월 d일 EEEE"
    static let dateFormatRecent = "오늘 a h:mm"
    static let dateFormatYesterday = "어제"
    
    static let defaultUUID = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
}
