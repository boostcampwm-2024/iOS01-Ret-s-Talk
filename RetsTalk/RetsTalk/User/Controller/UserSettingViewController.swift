//
//  UserViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import Combine
import SwiftUI
import UIKit

final class UserSettingViewController: UIHostingController<UserSettingView> {
    private let userSettingManager: UserSettingManageable
    
    // MARK: Init method
    
    init(userSettingManager: UserSettingManageable) {
        self.userSettingManager = userSettingManager
        guard let userSettingManager = userSettingManager as? UserSettingManager else {
            fatalError()
        }
        
        let userSettingView = UserSettingView(userSettingManager: userSettingManager)
        
        super.init(rootView: userSettingView)
    }

    required init?(coder: NSCoder) {
        let userDefaultsManager = UserDefaultsManager()
        self.userSettingManager = UserSettingManager(userDataStorage: userDefaultsManager)
        
        super.init(coder: coder)
    }

    // MARK: ViewController lifecycle method

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
    }
    
    // MARK: Custom method

    private func setUpNavigationBar() {
        title = Texts.navigationBarTitle
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemImage: .leftChevron),
            style: .plain,
            target: self,
            action: #selector(backwardButtonTapped)
        )
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem?.tintColor = .blazingOrange
        navigationItem.rightBarButtonItem?.tintColor = .blazingOrange
    }
    
    @objc private func backwardButtonTapped() {}
}

// MARK: - Constants

private extension UserSettingViewController {
    enum Texts {
        static let navigationBarTitle = "설정"
        static let leftBarButtonItemTitle = "회고"
    }
}
