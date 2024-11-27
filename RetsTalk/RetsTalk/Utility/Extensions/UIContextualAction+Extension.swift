//
//  UIContextualAction+Extension.swift
//  RetsTalk
//
//  Created by HanSeung on 11/27/24.
//

import UIKit

extension UIContextualAction {
    // 시스템 아이콘을 설정할 수 있는 메서드
    static func actionWithSystemImage(
        named imageName: String,
        tintColor: UIColor,
        action: @escaping () -> Void,
        completionHandler: @escaping (Bool) -> Void
    ) -> UIContextualAction {
        let contextualAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: {_, _, _ in
                action()
                completionHandler(true)
            })
        contextualAction.backgroundColor = .backgroundMain
        contextualAction.image =  UIImage.systemImage(named: imageName, tintColor: tintColor, scaleFactor: 1.2)
        
        return contextualAction
    }
}
