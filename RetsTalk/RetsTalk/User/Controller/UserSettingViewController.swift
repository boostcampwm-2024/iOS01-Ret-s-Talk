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
        super.setupNavigationBar()

        title = UserSettingViewTexts.navigationBarTitle

        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func setupDelegation() {
        super.setupDelegation()
        
        userSettingManager.alertable = self
    }
}

// MARK: - UserSettingManageableDelegate conformance

extension UserSettingViewController: UserSettingManageableAlertable {
    typealias Situation = UserSettingViewSituation

    func needNotificationPermission(_ userSettingManageable: any UserSettingManageable) {
        let confirmAction = UIAlertAction.confirm { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        presentAlert(for: .needNotifactionPermission, actions: [confirmAction, .close()])
    }

    func checkICloudState(_ userSettingManageable: any UserSettingManageable) {
        let confirmAction = UIAlertAction.confirm { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        presentAlert(for: .checkICloudState, actions: [confirmAction, .close()])
    }

    enum UserSettingViewSituation: AlertSituation {
        case needNotifactionPermission
        case checkICloudState

        var title: String {
            switch self {
            case .needNotifactionPermission:
                Texts.needNotificationPermissonTitle
            case .checkICloudState:
                Texts.checkICloudStateTitle
            }
        }
        var message: String {
            switch self {
            case .needNotifactionPermission:
                Texts.needNotificationPermissonMessage
            case .checkICloudState:
                Texts.checkICloudStateMessage
            }
        }
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
    static let needNotificationPermissonTitle = "알림 권한 요청"
    static let needNotificationPermissonMessage = "알림 권한이 비활성화되어 있습니다.\n알림 권한을 허용해주세요."
    static let checkICloudStateTitle = "iCloud 상태 확인 필요"
    static let checkICloudStateMessage = "iCloud 설정을 확인해 주세요."
}
