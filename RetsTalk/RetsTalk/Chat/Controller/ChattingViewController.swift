//
//  ChattingViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit
import SwiftUI
import Combine

final class ChattingViewController: UIViewController {
    private let chatView = ChatView()
    private let messageManager: MockMessageManager = MockMessageManager(
        messageManagerListener: MockMessageManagerListener()
    )
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatView.setTableViewDelegate(self)
        chatView.delegate = self

        addKeyboardObservers()
        messageManager.fetchMessages(offset: Numeric.initialOffset, amount: Numeric.amount)

        observeMessages()
    }
    
    override func loadView() {
        view = chatView
    }
  
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
  
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            chatView.updateBottomConstraintForKeyboard(height: keyboardHeight)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        chatView.updateBottomConstraintForKeyboard(height: 40)
    }

    private func observeMessages() {
        var previousMessageCount = messageManager.messages.count

        messageManager.messagePublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .print("🔵 Combine Debug") // Combine 스트림 디버그
            .sink { [weak self] newMessages in
                guard let self = self else { return }

                let oldCount = previousMessageCount
                let newCount = newMessages.count
                previousMessageCount = newCount
                guard oldCount < newCount else { return }

                let newIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                chatView.insertMessages(at: newIndexPaths)
            }
            .store(in: &cancellables)
    }
}

extension ChattingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageManager.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageManager.messages[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.contentConfiguration = UIHostingConfiguration {
            MessageCell(message: message.content, isUser: message.role == .user)
        }
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - ChatViewDelegate

extension ChattingViewController: ChatViewDelegate {
    func sendMessage(_ chatView: ChatView, with text: String) {
        let userMessage = Message(role: .user, content: text, createdAt: Date())
        // 실제로는 비동기 처리 or 반응형으로 처리가 되어야 함, 아직 미완된 기능이라 일단 넘어가도록 하였음
        Task {
            do {
                try await messageManager.send(userMessage)

                chatView.updateSendButtonState(isEnabled: true)
            } catch {
                print("response error")
            }
        }
    }
}

// MARK: - Constants

private extension ChattingViewController {
    enum Numeric {
        static let initialOffset = 0
        static let amount = 10
    }
}
