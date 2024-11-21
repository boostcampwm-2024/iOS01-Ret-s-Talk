//
//  AlertPresentableViewController.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/21/24.
//

import UIKit

class AlertPresentableViewController: UIViewController, AlertPresentable {
    func presentAlert(for situation: Situation, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: situation.title, message: situation.message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
}

extension AlertPresentableViewController {
    enum Situation {
        case end

        var title: String {
            switch self {
            case .end:
                "대화를 종료하시겠습니까?"
            }
        }

        var message: String {
            switch self {
            case .end:
                "더 이상 메시지를 입력할 수 없습니다."
            }
        }
    }
}
