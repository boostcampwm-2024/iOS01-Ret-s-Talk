//
//  NotificationManager.swift
//  RetsTalk
//
//  Created by HanSeung on 11/26/24.
//

import UserNotifications

final class NotificationManager: NotificationManageable {
    func checkAndRequestPermission(completion: @Sendable @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion(true)
            case .denied:
                completion(false)
            case .notDetermined:
                self?.requestPermission(completion: completion)
            @unknown default:
                completion(false)
            }
        }
    }

    private func requestPermission(completion: @Sendable @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard error == nil
            else {
                completion(false)
                return
            }
            
            completion(granted)
        }
    }
    
    func scheduleNotification(date: Date) {
        let center = UNUserNotificationCenter.current()
        let request = UNNotificationRequest(
            identifier: Texts.notificationIdentifier,
            content: notificationContent(),
            trigger: notificationTrigger(date)
        )
        center.add(request) { _ in }
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func notificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = Texts.randomNotificationBody
        content.body = Texts.notificationBody.randomElement() ?? Texts.notificationDefaultBody
        content.sound = UNNotificationSound.default
        return content
    }
    
    private func notificationTrigger(_ date: Date) -> UNNotificationTrigger {
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        return trigger
    }
}

private extension NotificationManager {
    enum Texts {
        static let notificationIdentifier = "RetsTalk.Notification.Reminder"
        static let notificationTitle = "회고 작성 알림"
        static let notificationBody = [
            "오늘은 어떤 일이 있었나요?",
            "오늘 무엇이 가장 기억에 남았나요?",
            "오늘 하루도 고생 많았어요! 회고의 시간을 가져보세요.",
            "하루를 마친 후, 잠시 회고하며 휴식을 취해보세요.",
            "오늘 무엇을 배웠나요?",
            "하루를 마무리하며 당신의 생각을 기록해 보세요. 내일은 더 나은 당신이 될 거예요.",
        ]
        static let notificationDefaultBody = "오늘은 어떤 일이 있었나요?"
        
        static var randomNotificationBody: String {
            Texts.notificationBody.randomElement() ?? Texts.notificationDefaultBody
        }
    }
}
