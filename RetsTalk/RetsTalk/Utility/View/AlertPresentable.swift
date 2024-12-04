//
//  AlertPresentable.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

import UIKit

@MainActor
protocol AlertPresentable {
    associatedtype Situation: AlertSituation
    
    /// 알림을 화면에 표시합니다.
    /// 알림의 제목과 메시지는 Situation 타입에서 제공된 title과 message를 사용하며, 사용자가 선택할 수 있는 액션들은 actions 배열에 추가됩니다.
    /// - Parameters:
    ///   - situation: 알림의 제목과 메시지를 제공하는 객체입니다. Situation 타입은 AlertSituation 프로토콜을 준수해야 합니다.
    ///   - actions: 알림에 추가할 액션들입니다. 각 액션은 UIAlertAction 객체로 제공됩니다.
    func presentAlert(for situation: Situation, actions: [UIAlertAction])
}

extension AlertPresentable where Self: UIViewController {
    func presentAlert(for situation: Situation, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: situation.title, message: situation.message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
}

protocol AlertSituation {
    /// 알림의 제목을 반환하는 문자열입니다.
    var title: String { get }
    /// 알림의 내용을 담고 있는 문자열입니다.
    var message: String { get }
}
