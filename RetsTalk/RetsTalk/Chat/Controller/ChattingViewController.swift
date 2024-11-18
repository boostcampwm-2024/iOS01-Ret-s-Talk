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
    
    private let messages: [Message] = [
        Message(role: .assistant, content: "오늘 하루는 어떠셨나요?", createdAt: Date()),
        Message(role: .user, content: "데모를 진행했어요~", createdAt: Date()),
        Message(role: .assistant, content: "그렇군요 잘했어요~", createdAt: Date()),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatView.setTableViewDelegate(self)
        
        addKeyboardObservers()
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
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        
        cell.contentConfiguration = UIHostingConfiguration {
            MessageCell(message: message.content, isUser: message.role == .user)
        }
        cell.backgroundColor = .clear
        
        return cell
    }
}
