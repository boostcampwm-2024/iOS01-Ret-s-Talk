//
//  UserData.swift
//  RetsTalk
//
//  Created by HanSeung on 11/25/24.
//

import Foundation

struct UserData {
    var userID: String
    var isCloudSyncOn: Bool
    var isNotificationOn: Bool
    var notificationTime: Date
    var cloudAddress: String
    var nickname: String
}

// MARK: - EntityRepresentable conformance

extension UserData: EntityRepresentable {
    var mappingDictionary: [String: Any] {
        [
            "userID": userID,
            "isCloudSyncOn": isCloudSyncOn,
            "isNotificationOn": isNotificationOn,
            "notificationTime": notificationTime,
            "cloudAddress": cloudAddress,
            "nickname": nickname,
        ]
    }
    
    init(dictionary: [String: Any]) {
        userID = dictionary["userID"] as? String ?? ""
        isCloudSyncOn = dictionary["isCloudSyncOn"] as? Bool ?? false
        isNotificationOn = dictionary["isNotificationOn"] as? Bool ?? false
        notificationTime = dictionary["notificationTime"] as? Date ?? Date()
        cloudAddress = dictionary["cloudAddress"] as? String ?? ""
        nickname = dictionary["nickname"] as? String ?? ""
    }
    
    static let entityName: String = "UserDataEntity"
}
