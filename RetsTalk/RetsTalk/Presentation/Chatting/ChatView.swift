//
//  ChatView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit

final class ChatView: UIView {
    private let chattingTableView = UITableView()
    private let messageInputView = MessageInputView()
    private var messageInputViewHeightConstraint: NSLayoutConstraint!

    func setUp() {
        messageInputViewSetUp()
        chattingTableViewSetUp()
    }
    
    private func messageInputViewSetUp() {
        self.addSubview(messageInputView)
        messageInputView.delegate = self
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.backgroundColor = .blue
        messageInputViewHeightConstraint = messageInputView.heightAnchor.constraint(equalToConstant: 54)

        NSLayoutConstraint.activate([
            messageInputViewHeightConstraint,
            messageInputView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            messageInputView.leftAnchor.constraint(equalTo: self.leftAnchor),
            messageInputView.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
    }
    
    private func chattingTableViewSetUp() {
        self.addSubview(chattingTableView)
        
        chattingTableView.delegate = self
        chattingTableView.dataSource = self
        chattingTableView.translatesAutoresizingMaskIntoConstraints = false
        chattingTableView.separatorStyle = .none
        
        NSLayoutConstraint.activate([
            chattingTableView.topAnchor.constraint(equalTo: self.topAnchor),
            chattingTableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            chattingTableView.leftAnchor.constraint(equalTo: self.leftAnchor),
            chattingTableView.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
    }
}

extension ChatView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// MARK: - MessageInputViewDelegate conformance

extension ChatView: MessageInputViewDelegate {
    func updateMessageInputViewHeight(to height: CGFloat) {
        messageInputViewHeightConstraint.constant = height
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }
}
