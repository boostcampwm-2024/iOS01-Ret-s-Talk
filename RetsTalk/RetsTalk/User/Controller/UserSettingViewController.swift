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
        let acceptAction = UIAlertAction(title: Texts.accept, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        let cancelAction = UIAlertAction(title: Texts.cancel, style: .cancel)
        presentAlert(for: .needNotifactionPermission, actions: [acceptAction, cancelAction])
    }

    func checkICloudState(_ userSettingManageable: any UserSettingManageable) {
        let acceptAction = UIAlertAction(title: Texts.accept, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        let cancelAction = UIAlertAction(title: Texts.cancel, style: .cancel)
        presentAlert(for: .checkICloudState, actions: [acceptAction, cancelAction])
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
    static let accept = "확인"
    static let cancel = "취소"
    static let needNotificationPermissonTitle = "알림 권한 요청"
    static let needNotificationPermissonMessage = "알림 권한이 꺼져있습니다. \r\n 알림 권한을 허용해주세요."
    static let checkICloudStateTitle = "애플 계정 확인"
    static let checkICloudStateMessage = "아이클라우드 상태를 확인해주세요."
}
