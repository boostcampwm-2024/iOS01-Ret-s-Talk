//
//  ChattingViewController.swift
//  RetsTalk
//
//  Created by KimMinSeok on 11/13/24.
//

import UIKit
import SwiftUI

final class ChattingViewController: UIViewController {
    private let chatView = ChatView()
    private let messageManager: MockMessageManager = MockMessageManager(
        messageManagerListener: MockMessageManagerListener()
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatView.setTableViewDelegate(self)
        chatView.delegate = self

        addKeyboardObservers()
        messageManager.messages = messageManager.fetchMessages(offset: 0, amount: 10)
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

extension ChattingViewController: ChatViewDelegate {
    func sendMessage(with text: String) {
        let initialMessageCount = messageManager.messages.count
        let userMessage = Message(role: .user, content: text, createdAt: Date())
        // 실제로는 비동기 처리 or 반응형으로 처리가 되어야 함, 아직 미완된 기능이라 일단 넘어가도록 하였음
        messageManager.messages.append(userMessage)
        let userIndexPath = IndexPath(row: initialMessageCount, section: 0)

        chatView.insertMessages(at: [userIndexPath])
        chatView.scrollToBottom()

        Task {
            do {
                let responseMessage = try await messageManager.send(userMessage)
                messageManager.messages.append(responseMessage)

                let responseIndexPath = IndexPath(row: messageManager.messages.count - 1, section: 0)
                chatView.insertMessages(at: [responseIndexPath])

                chatView.scrollToBottom()
                chatView.updateSendButtonState(isEnabled: true)
            } catch {
                print("response error")
            }
        }
    }
}
