//
//  RetrospectViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/18/24.
//

import UIKit

final class RetrospectListViewController: UIViewController {
    
    // MARK: Lifecycle method

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundMain // 임시 배경색 설정
        setUpNavigationBar()
    }
    
    // MARK: Custom method

    private func setUpNavigationBar() {
        title = Texts.titleLabelText
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - Constants

extension RetrospectListViewController {
    enum Texts {
        static let titleLabelText = "회고"
    }
}
