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
        Message(role: .user, content: "데모를 진행했어요~", createdAt: Date()),
        Message(role: .assistant, content: "그렇군요 잘했어요~", createdAt: Date()),
        Message(role: .user, content: "데모를 진행했어요~", createdAt: Date()),
        Message(role: .assistant, content: "그렇군요 잘했어요~", createdAt: Date()),
        Message(role: .user, content: "데모를 진행했어요~", createdAt: Date()),
        Message(role: .assistant, content: "그렇군요 잘했어요~", createdAt: Date()),
        Message(role: .user, content: "데모를 진행했어요~", createdAt: Date()),
        Message(role: .assistant, content: "그렇군요 잘했어요~", createdAt: Date()),
        Message(role: .user, content: "데모를 진행했어요~", createdAt: Date()),
        Message(role: .assistant, content: "그렇군요 잘했어요~", createdAt: Date()),
        Message(role: .user, content: "데모를 진행했어요~", createdAt: Date()),
        Message(role: .assistant, content: "그렇군요 잘했어요~", createdAt: Date()),
    ]
    
    // MARK: lifecycle method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        addTapGestureOfDismissingKeyboard()
        addKeyboardObservers()
        chatView.setTableViewDelegate(self)
    }
    
    override func loadView() {
        view = chatView
    }
    
    // MARK: custom method

    private func addTapGestureOfDismissingKeyboard() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setUpNavigationBar() {
        title = "2024년 11월 19일" // 모델 연결 전 임시 하드코딩
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemImage: .leftChevron),
            style: .plain,
            target: self,
            action: #selector(backwardButtonTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Texts.rightBarButtonTitle,
            style: .plain,
            target: self,
            action: #selector(endChattingButtonTapped)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .blazingOrange
        navigationItem.rightBarButtonItem?.tintColor = .blazingOrange
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
    
    @objc private func backwardButtonTapped() {
        // navigationController: pop 작업
    }
    
    @objc private func endChattingButtonTapped() {
        // 대화끝내기 alert 작업
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource conformance

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

// MARK: - Constants

extension ChattingViewController {
    enum Texts {
        static let leftBarButtonImageName = "chevron.left"
        static let rightBarButtonTitle = "끝내기"
    }
}
