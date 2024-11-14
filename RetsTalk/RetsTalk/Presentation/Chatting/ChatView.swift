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
        
        DispatchQueue.main.async { [weak self] in
            self?.scrollToBottom()
            self?.updateScrollEnabled()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpLayout()
        
        DispatchQueue.main.async { [weak self] in
            self?.scrollToBottom()
            self?.updateScrollEnabled()
        }
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
    }
    
    func updateScrollEnabled() {
        let contentHeight = chattingTableView.contentSize.height
        let tableHeight = chattingTableView.frame.height
        chattingTableView.isScrollEnabled = contentHeight > tableHeight
    }
    
    func scrollToBottom() {
        let rows = chattingTableView.numberOfRows(inSection: 0)
        guard rows > 0 else { return }
        
        let indexPath = IndexPath(row: rows - 1, section: 0)
        chattingTableView.scrollToRow(at: indexPath,
                                      at: .bottom,
                                      animated: false)
    }
}
