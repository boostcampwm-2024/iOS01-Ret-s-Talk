//
//  ChattingViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit

final class ChattingViewController: UIViewController {
    private let chattingTableView = UITableView()
    private let messageInputView = MessageInputView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageInputViewSetUp()
        chattingTableViewSetUp()
    }
    
    private func chattingTableViewSetUp() {
        view.addSubview(chattingTableView)
        
        chattingTableView.delegate = self
        chattingTableView.dataSource = self
        chattingTableView.translatesAutoresizingMaskIntoConstraints = false
        chattingTableView.separatorStyle = .none
        
        NSLayoutConstraint.activate([
            chattingTableView.topAnchor.constraint(equalTo: view.topAnchor),
            chattingTableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            chattingTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            chattingTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    private func messageInputViewSetUp() {
        view.addSubview(messageInputView)
        
        messageInputView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            messageInputView.heightAnchor.constraint(equalToConstant: 54),
            messageInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messageInputView.leftAnchor.constraint(equalTo: view.leftAnchor),
            messageInputView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
        ])
    }
}

extension ChattingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
