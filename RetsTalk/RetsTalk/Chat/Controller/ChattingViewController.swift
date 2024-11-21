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

    // MARK: ViewController lifecycle method
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatView.setTableViewDelegate(self)
        chatView.delegate = self
      
        setUpNavigationBar()
        addTapGestureOfDismissingKeyboard()
        addKeyboardObservers()
        
        messageManager.fetchMessages(offset: Numeric.initialOffset, amount: Numeric.amount)

        observeMessages()
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

    private func observeMessages() {
        var previousMessageCount = messageManager.retrospectSubject.value.chat.count

        messageManager.retrospectSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] newMessages in
                guard let self = self else { return }

                let oldCount = previousMessageCount
                let newCount = newMessages.chat.count
                previousMessageCount = newCount
                guard oldCount < newCount else { return }

                let newIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                chatView.insertMessages(at: newIndexPaths)
            }
            .store(in: &cancellables)
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
        return messageManager.retrospectSubject.value.chat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageManager.retrospectSubject.value.chat[indexPath.row]

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

                chatView.updateRequestInProgressState(false)
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

    enum Texts {
        static let leftBarButtonImageName = "chevron.left"
        static let rightBarButtonTitle = "끝내기"
    }
}
