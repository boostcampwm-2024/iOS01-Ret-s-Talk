//
//  NotificationManager.swift
//  RetsTalk
//
//  Created by HanSeung on 11/26/24.
//

import UserNotifications

final class NotificationManager: NotificationManageable {
    static let shared = NotificationManager()
        
    private init() {}
    
    func checkAndRequestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus != .authorized else {
                completion(true)
                return
            }
            
            self.requestPermission(completion: completion)
        }
    }

    private func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard let error = error else {
                completion(granted)
                return
            }
            
            completion(false)
        }
    }
    
    func scheduleNotification(date: Date) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = Texts.notificationTitle
        content.body = Texts.notificationBody
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request) { _ in }
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

private extension NotificationManager {
    enum Texts {
        static let notificationTitle = "임시타이틀"
        static let notificationBody = "임시내용"
    }
}
