//
//  NotificationManager.swift
//  RetsTalk
//
//  Created by HanSeung on 11/26/24.
//

import UserNotifications

final class NotificationManager: NotificationManageable {
    func requestNotification(_ isOn: Bool, date: Date) async -> Bool {
        if isOn {
            let isPermissionAllowed = await checkAndRequestPermission()
            if isPermissionAllowed {
                scheduleNotification(date: date)
            } else {
                cancelNotification()
                return false
            }
            return true
        } else {
            cancelNotification()
            return true
        }
    }

    private func checkAndRequestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return await self.requestPermission()
        case .denied:
            return false
        case .authorized, .provisional, .ephemeral:
            return true
        @unknown default:
            return false
        }
    }

    private func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {}
        return false
    }

    private func scheduleNotification(date: Date) {
        let center = UNUserNotificationCenter.current()
        let request = UNNotificationRequest(
            identifier: Texts.notificationIdentifier,
            content: notificationContent(),
            trigger: notificationTrigger(date)
        )
        center.add(request) { _ in }
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func notificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = Texts.notificationTitle
        content.body = Texts.randomNotificationBody
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
