//
//  ChattingViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit

final class ChattingViewController: UIViewController {
    
    private let chatView = ChatView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatViewSetUp()
    }
    
    private func chatViewSetUp() {
        view.addSubview(chatView)
        chatView.setUp()
        chatView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chatView.topAnchor.constraint(equalTo: view.topAnchor),
            chatView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            chatView.leftAnchor.constraint(equalTo: view.leftAnchor),
            chatView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
}
