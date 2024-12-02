//
//  BaseHostingViewController.swift
//  RetsTalk
//
//  Created by HanSeung on 11/28/24.
//

import SwiftUI

class BaseHostingViewController<Content: View>: UIHostingController<Content> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .blazingOrange
    }
}
