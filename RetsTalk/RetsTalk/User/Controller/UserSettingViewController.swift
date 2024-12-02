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
    UIHostingController<UserSettingView<T>>, AlertPresentable {
    private let userSettingManager: T
    
    // MARK: Init method
    
    init(userSettingManager: T) {
        self.userSettingManager = userSettingManager
        let userSettingView = UserSettingView(
            userSettingManager: userSettingManager
        )

        super.init(rootView: userSettingView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: ViewController lifecycle method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        userSettingManager.delegate = self
    }
    
    // MARK: Custom method
    
    private func setUpNavigationBar() {
        title = UserSettingViewTexts.navigationBarTitle
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem?.tintColor = .blazingOrange
        navigationItem.rightBarButtonItem?.tintColor = .blazingOrange
    }
    
    @objc private func backwardButtonTapped() {}
}

// MARK: - UserSettingManageableDelegate conformance

extension UserSettingViewController: UserSettingManageableDelegate {
    typealias Situation = UserSettingViewSituation

    nonisolated func alertNeedNotificationPermission() {
        Task { @MainActor in
            let alertAction = UIAlertAction(title: UserSettingViewTexts.accept, style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            let cancel = UIAlertAction(title: UserSettingViewTexts.cancel, style: .cancel)
            presentAlert(for: .needNotifactionPermission, actions: [alertAction, cancel])
        }
    }

    func presentAlert(for situation: UserSettingViewSituation, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: situation.title, message: situation.message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }

    enum UserSettingViewSituation: AlertSituation {
        case needNotifactionPermission

        var title: String { UserSettingViewTexts.needNotificationPermissonTitle }
        var message: String { UserSettingViewTexts.needNotificationPermissonMessage }
    }
}

// MARK: - Constants

enum UserSettingViewMetrics { }

enum UserSettingViewNumerics { }

enum UserSettingViewTexts {
    static let navigationBarTitle = "설정"
    static let leftBarButtonItemTitle = "회고"
    
    static let accept = "확인"
    static let cancel = "취소"
    static let needNotificationPermissonTitle = "알림 권한 요청"
    static let needNotificationPermissonMessage = "알림 권한이 꺼져있습니다. \r\n 알림 권한을 허용해주세요."
}
