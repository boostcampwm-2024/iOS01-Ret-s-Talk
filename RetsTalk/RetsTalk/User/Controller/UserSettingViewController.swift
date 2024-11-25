//
//  UserViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/19/24.
//

import UIKit
import SwiftUI

final class UserSettingViewController: UIViewController {
    let userSettingView = UserSettingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        setUpHostingController(userSettingView)
    }
    
    private func setUpHostingController(_ hostingView: some View) {
        let hostingController = UIHostingController(rootView: hostingView)
        
        addChild(hostingController)
        hostingController.view.frame = self.view.bounds
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
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
    
    @objc private func backwardButtonTapped() {
        
    }
}

// MARK: - UserSettingViewDelegate conformance

extension UserSettingViewController: UserSettingViewDelegate {
    func didChangeNickname(_ userSettingView: UserSettingView, nickname: String) {
        
    }
    
    func didToggleCloudSync(_ userSettingView: UserSettingView, isOn: Bool) {
        
    }
    
    func didToggleNotification(_ userSettingView: UserSettingView, isOn: Bool, selectedDate: Date) {
        
    }
}

// MARK: - Constants

private extension UserSettingViewController {
    enum Texts {
        static let navigationBarTitle = "설정"
        static let leftBarButtonItemTitle = "회고"
    }
}
