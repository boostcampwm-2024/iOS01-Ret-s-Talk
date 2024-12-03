//
//  UserViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Combine
import SwiftUI
import UIKit

final class UserSettingViewController<T: UserSettingManageable>: UIHostingController<UserSettingView<T>> {
    private let userSettingManager: T
    private let notificationManager: NotificationManageable
    
    // MARK: Init method
    
    init(userSettingManager: T, notificationManager: NotificationManageable) {
        self.userSettingManager = userSettingManager
        self.notificationManager = notificationManager
        let userSettingView = UserSettingView(
            userSettingManager: userSettingManager,
            notificationManager: notificationManager
        )
        
        super.init(rootView: userSettingView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: ViewController lifecycle method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
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

// MARK: - Constants

enum UserSettingViewMetrics { }

enum UserSettingViewNumerics { }

enum UserSettingViewTexts {
    static let navigationBarTitle = "설정"
    static let leftBarButtonItemTitle = "회고"
}
