//
//  ChatView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit

@MainActor
final class ChatView: UIView {
    private let chattingTableView = UITableView()
    private let messageInputView = MessageInputView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollToBottom()
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
            
            chattingTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            chattingTableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            chattingTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chattingTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        chattingTableView.separatorStyle = .none
        chattingTableView.backgroundColor = UIColor.appColor(.backgroundMain)
        chattingTableView.allowsSelection = false
    }
    
    func scrollToBottom() {
        let rows = chattingTableView.numberOfRows(inSection: 0)
        guard 0 < rows else { return }
        
        let indexPath = IndexPath(row: rows - 1, section: 0)
        chattingTableView.scrollToRow(
            at: indexPath,
            at: .bottom,
            animated: false
        )
    }
    
    func setTableViewDelegate(_ delegate: UITableViewDelegate & UITableViewDataSource) {
        chattingTableView.delegate = delegate
        chattingTableView.dataSource = delegate
    }
}
