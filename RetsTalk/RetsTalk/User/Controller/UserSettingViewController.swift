//
//  UserViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Combine
import SwiftUI
import UIKit

final class UserSettingViewController<T: UserSettingManageable>:
    BaseHostingViewController<UserSettingView<T>>, AlertPresentable {
    private let userSettingManager: T
    
    // MARK: Init method
    
    init(userSettingManager: T) {
        self.userSettingManager = userSettingManager
        let userSettingView = UserSettingView(userSettingManager: userSettingManager)

        super.init(rootView: userSettingView)
    }
    
    required init?(coder: NSCoder) { fatalError() }

    // MARK: RetsTalk lifecycle method

    override func setupNavigationBar() {
        title = UserSettingViewTexts.navigationBarTitle

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem?.tintColor = .blazingOrange
        navigationItem.rightBarButtonItem?.tintColor = .blazingOrange
    }

    override func setupDelegation() {
        super.setupDelegation()
        
        userSettingManager.permissionAlertDelegate = self
    }
}

// MARK: - UserSettingManageableDelegate conformance

extension UserSettingViewController: UserSettingManageableDelegate {
    typealias Situation = UserSettingViewSituation

    func alertNeedNotificationPermission(_ userSettingManageable: any UserSettingManageable) {
        let acceptAction = UIAlertAction(title: Texts.accept, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        let cancelAction = UIAlertAction(title: Texts.cancel, style: .cancel)
        presentAlert(for: .needNotifactionPermission, actions: [acceptAction, cancelAction])
    }

    enum UserSettingViewSituation: AlertSituation {
        case needNotifactionPermission

        var title: String { Texts.needNotificationPermissonTitle }
        var message: String { Texts.needNotificationPermissonMessage }
    }
}

// MARK: - Constants

enum UserSettingViewMetrics { }

enum UserSettingViewNumerics { }

enum UserSettingViewTexts {
    static let navigationBarTitle = "설정"
    static let leftBarButtonItemTitle = "회고"
}

private enum Texts {
    static let accept = "확인"
    static let cancel = "취소"
    static let needNotificationPermissonTitle = "알림 권한 요청"
    static let needNotificationPermissonMessage = "알림 권한이 꺼져있습니다. \r\n 알림 권한을 허용해주세요."
}
