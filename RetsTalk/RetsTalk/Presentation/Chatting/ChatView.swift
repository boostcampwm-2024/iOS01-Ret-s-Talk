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
    private var messageInputViewHeightConstraint: NSLayoutConstraint?

    func setUp() {
        messageInputViewSetUp()
        chattingTableViewSetUp()
    }
    
    private func messageInputViewSetUp() {
        self.addSubview(messageInputView)
        messageInputView.delegate = self
        messageInputViewHeightConstraint = messageInputView.heightAnchor.constraint(equalToConstant: 54)
        guard let messageInputViewHeightConstraint = messageInputViewHeightConstraint else {
            fatalError("chatViewBottomConstraint가 초기화되지 않았습니다.")
        }
        
        NSLayoutConstraint.activate([
            messageInputViewHeightConstraint,
            messageInputView.bottomAnchor.constraint(equalTo: bottomAnchor),
            messageInputView.leftAnchor.constraint(equalTo: leftAnchor),
            messageInputView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
    
    private func chattingTableViewSetUp() {
        self.addSubview(chattingTableView)
        
        chattingTableView.delegate = self
        chattingTableView.dataSource = self
        chattingTableView.translatesAutoresizingMaskIntoConstraints = false
        chattingTableView.separatorStyle = .none
        
        NSLayoutConstraint.activate([
            chattingTableView.topAnchor.constraint(equalTo: topAnchor),
            chattingTableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            chattingTableView.leftAnchor.constraint(equalTo: leftAnchor),
            chattingTableView.rightAnchor.constraint(equalTo: rightAnchor),
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
        guard let messageInputViewHeightConstraint = messageInputViewHeightConstraint else {
            fatalError("chatViewBottomConstraint가 초기화되지 않았습니다.")
        }
        
        messageInputViewHeightConstraint.constant = height
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }
}
