//
//  UserData.swift
//  RetsTalk
//
//  Created by HanSeung on 11/25/24.
//

import Foundation

struct UserData: EntityRepresentable {
    var isCloudSyncOn: Bool
    var isNotificationOn: Bool
    var notificationTime: Date
    var cloudAddress: String
    var nickname: String
    
    var mappingDictionary: [String : Any] {
        [
            "isCloudSyncOn": isCloudSyncOn,
            "isNotificationOn": isNotificationOn,
            "notificationTime": notificationTime,
            "cloudAddress": cloudAddress,
            "nickname": nickname
        ]
    }
    
    init(dictionary: [String : Any]) {
        isCloudSyncOn = dictionary["isCloudSyncOn"] as? Bool ?? false
        isNotificationOn = dictionary["isNotificationOn"] as? Bool ?? false
        notificationTime = dictionary["notificationTime"] as? Date ?? Date()
        cloudAddress = dictionary["cloudAddress"] as? String ?? ""
        nickname = dictionary["nickname"] as? String ?? ""
    }
    
    static let entityName: String = "UserData"
}
