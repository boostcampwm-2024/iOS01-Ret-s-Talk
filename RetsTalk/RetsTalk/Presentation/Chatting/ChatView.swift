//
//  ChatView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit

final class ChatView: UIView {
    let chattingTableView = UITableView()
    let messageInputView = MessageInputView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpLayout()
    }
    
    private func setUpLayout() {
        addSubview(messageInputView)
        addSubview(chattingTableView)
        
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        chattingTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageInputView.heightAnchor.constraint(equalToConstant: 54),
            messageInputView.bottomAnchor.constraint(equalTo: bottomAnchor),
            messageInputView.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            chattingTableView.topAnchor.constraint(equalTo: topAnchor),
            chattingTableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            chattingTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chattingTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
