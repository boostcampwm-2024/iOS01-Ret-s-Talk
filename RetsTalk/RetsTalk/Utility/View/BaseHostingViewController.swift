//
//  BaseHostingViewController.swift
//  RetsTalk
//
//  Created by HanSeung on 11/28/24.
//

import SwiftUI

class BaseHostingViewController<Content: View>: UIHostingController<Content> {

    // MARK: ViewController lifecyfcle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDelegation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }

    // MARK: RetsTalk lifecycle

    func setupDelegation() {}

    func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .blazingOrange
    }
}
