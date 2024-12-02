//
//  ChatView.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit

@MainActor
protocol ChatViewDelegate: AnyObject {
    func sendMessage(_ chatView: ChatView, with text: String)
}

final class ChatView: BaseView {
    
    // MARK: Subviews
    
    private let chatTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.scrollsToTop = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .backgroundMain
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
        return tableView
    }()
    private let messageInputView = MessageInputView()
    
    // MARK: Layout constraint
    
    private var messageInputViewHeightConstraint: NSLayoutConstraint?
    private var chatViewBottomConstraint: NSLayoutConstraint?

    // MARK: RetsTalk lifecycle
    
    override func setupStyles() {
        super.setupStyles()
        
        backgroundColor = .backgroundMain
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(messageInputView)
        addSubview(chatTableView)
        
        messageInputView.delegate = self
    }
    
    override func setupSubviewLayouts() {
        super.setupSubviewLayouts()
        
        setupChatTableViewLayouts()
        setupMessageInputViewLayouts()
    }
    
    // MARK: Delegation
    
    weak var delegate: ChatViewDelegate?
    
    func setChatTableViewDelegate(_ delegate: UITableViewDelegate & UITableViewDataSource) {
        chatTableView.delegate = delegate
    }
    
    func setChatTableViewDataSource(_ delegate: UITableViewDataSource) {
        chatTableView.dataSource = delegate
    }
    
    // MARK: TableView actions
    
    func scrollToBottom() {
        let rows = chatTableView.numberOfRows(inSection: 0)
        guard 0 < rows else { return }
        
        let indexPath = IndexPath(row: rows - 1, section: 0)
        chatTableView.scrollToRow(
            at: indexPath,
            at: .bottom,
            animated: false
        )
    }
    
    func insertMessages(at indexPaths: [IndexPath]) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        chatTableView.insertRows(at: indexPaths, with: .none)
        CATransaction.commit()
    }
    
    // MARK: Keyboard action
    
    func updateLayoutForKeyboard(using keyboardInfo: KeyboardInfo) {
        chatViewBottomConstraint?.constant = min(-(keyboardInfo.frame.height - safeAreaInsets.bottom), 0)
        UIView.animate(withDuration: keyboardInfo.animationDuration) { [self] in
            layoutIfNeeded()
        }
    }
    
    // MARK: Input state handling
    
    func updateRequestInProgressState(_ state: Bool) {
        messageInputView.updateRequestInProgressState(state)
    }
}

// MARK: - MessageInputViewDelegate

extension ChatView: MessageInputViewDelegate {
    func sendMessage(_ messageInputView: MessageInputView, with text: String) {
        delegate?.sendMessage(self, with: text)
    }
    
    func updateMessageInputViewHeight(_ messageInputView: MessageInputView, to height: CGFloat) {
        guard let messageInputViewHeightConstraint = messageInputViewHeightConstraint else {
            fatalError("chatViewBottomConstraint가 초기화되지 않았습니다.")
        }
        
        messageInputViewHeightConstraint.constant = height
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Subviews layouts

fileprivate extension ChatView {
    func setupChatTableViewLayouts() {
        NSLayoutConstraint.activate([
            chatTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            chatTableView.leftAnchor.constraint(equalTo: leftAnchor),
            chatTableView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
    
    func setupMessageInputViewLayouts() {
        let messageInputViewHeightConstraint = messageInputView.heightAnchor.constraint(
            equalToConstant: Metrics.messageInputViewHeight
        )
        let messageInputViewBottomConstraint = messageInputView.bottomAnchor.constraint(
            equalTo: safeAreaLayoutGuide.bottomAnchor
        )
        NSLayoutConstraint.activate([
            messageInputViewHeightConstraint,
            messageInputViewBottomConstraint,
            messageInputView.leftAnchor.constraint(equalTo: leftAnchor),
            messageInputView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
        
        self.messageInputViewHeightConstraint = messageInputViewHeightConstraint
        chatViewBottomConstraint = messageInputViewBottomConstraint
    }
}

// MARK: - Constants

private extension ChatView {
    enum Metrics {
        static let messageInputViewHeight = 54.0
        static let chatViewBottomFromBottom = -40.0
    }
}
