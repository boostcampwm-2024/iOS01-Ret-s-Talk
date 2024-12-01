//
//  NotificationManageable.swift
//  RetsTalk
//
//  Created by HanSeung on 11/26/24.
//

import Foundation

protocol NotificationManageable: Sendable {
    func checkAndRequestPermission(completion: @Sendable @escaping (Bool) -> Void)
    func scheduleNotification(date: Date)
    func cancelNotification()
    
    func requestNotification(_ isOn: Bool, date: Date, completion: @Sendable @escaping (Bool) -> Void)
}
