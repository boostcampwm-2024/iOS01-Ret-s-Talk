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

extension UserSettingViewController: UserSettingManageableDelegate {
    typealias Situation = UserSettingViewSituation

    enum UserSettingViewSituation: AlertSituation {
        case needNotifactionPermission

        var title: String {
            "알림 권한 필요"
        }
        var message: String {
            guard let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
            else { return "알림 권한이 필요합니다." }
            
            let message = "\(appName)이(가) 접근 허용되어 있지않습니다. \r\n 설정화면으로 가시겠습니까?"

            return message
        }
    }

    nonisolated func alertNeedNotificationPermission() {
        Task { @MainActor in
            let alertAction = UIAlertAction(title: "moveToSetting", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            let cancel = UIAlertAction(title: "cancel", style: .cancel)
            presentAlert(for: .needNotifactionPermission, actions: [alertAction, cancel])
        }
    }

    func presentAlert(for situation: UserSettingViewSituation, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: situation.title, message: situation.message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
}

// MARK: - Constants

enum UserSettingViewMetrics { }

enum UserSettingViewNumerics { }

enum UserSettingViewTexts {
    static let navigationBarTitle = "설정"
    static let leftBarButtonItemTitle = "회고"
}
